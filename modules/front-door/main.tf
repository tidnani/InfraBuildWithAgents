resource "azurerm_cdn_frontdoor_profile" "main" {
  name                = "${var.name_prefix}-afd"
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_AzureFrontDoor"
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "main" {
  name                     = "${var.name_prefix}-endpoint"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  tags                     = var.tags
}

# ── WAF Policy ────────────────────────────────────────────────────────────────

resource "azurerm_cdn_frontdoor_firewall_policy" "main" {
  name                              = replace("${var.name_prefix}waf", "-", "")
  resource_group_name               = var.resource_group_name
  sku_name                          = azurerm_cdn_frontdoor_profile.main.sku_name
  enabled                           = true
  mode                              = var.waf_mode
  redirect_url                      = null
  custom_block_response_status_code = 403
  tags                              = var.tags

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.1"
    action  = "Block"
  }
}

# ── Security Policy (WAF ↔ Endpoint) ─────────────────────────────────────────

resource "azurerm_cdn_frontdoor_security_policy" "main" {
  name                     = "${var.name_prefix}-security-policy"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.main.id
      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.main.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}

# ── Origin Group ──────────────────────────────────────────────────────────────

resource "azurerm_cdn_frontdoor_origin_group" "app_service" {
  name                     = "${var.name_prefix}-og-appservice"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.main.id
  session_affinity_enabled = false

  load_balancing {
    sample_size                        = 4
    successful_samples_required        = 3
    additional_latency_in_milliseconds = 50
  }

  health_probe {
    interval_in_seconds = 30
    path                = "/health"
    protocol            = "Https"
    request_type        = "GET"
  }
}

# ── Origin ────────────────────────────────────────────────────────────────────

resource "azurerm_cdn_frontdoor_origin" "app_service" {
  name                          = "${var.name_prefix}-origin-appservice"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.app_service.id
  enabled                       = true

  certificate_name_check_enabled = true
  host_name                      = var.app_service_hostname
  origin_host_header             = var.app_service_hostname
  priority                       = 1
  weight                         = 1000

  private_link {
    request_message        = "Front Door private link request"
    location               = var.location
    private_link_target_id = var.app_service_resource_id
    target_type            = "sites"
  }
}

# ── Route ─────────────────────────────────────────────────────────────────────

resource "azurerm_cdn_frontdoor_route" "main" {
  name                          = "${var.name_prefix}-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.main.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.app_service.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.app_service.id]
  enabled                       = true

  forwarding_protocol    = "HttpsOnly"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]

  cdn_frontdoor_origin_path = "/"

  cache {
    query_string_caching_behavior = "IgnoreQueryString"
    compression_enabled           = true
    content_types_to_compress = [
      "application/json",
      "application/javascript",
      "text/css",
      "text/html",
      "text/javascript",
      "text/plain",
    ]
  }
}

# ── Diagnostic Settings ───────────────────────────────────────────────────────

resource "azurerm_monitor_diagnostic_setting" "front_door" {
  name                       = "${var.name_prefix}-afd-diag"
  target_resource_id         = azurerm_cdn_frontdoor_profile.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "FrontDoorAccessLog"
  }

  enabled_log {
    category = "FrontDoorHealthProbeLog"
  }

  enabled_log {
    category = "FrontDoorWebApplicationFirewallLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
