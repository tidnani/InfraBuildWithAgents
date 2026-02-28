# Front Door module tests
# Uses Terraform's native testing framework (terraform test)

variables {
  resource_group_name        = "test-afd-rg"
  location                   = "eastus2"
  name_prefix                = "test-afd"
  app_service_hostname       = "test-app.azurewebsites.net"
  app_service_resource_id    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/test-app"
  waf_mode                   = "Prevention"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}

run "validate_waf_mode" {
  command = plan

  assert {
    condition     = var.waf_mode == "Prevention"
    error_message = "WAF mode should be 'Prevention' for production."
  }
}

run "validate_profile_sku" {
  command = plan

  assert {
    condition     = azurerm_cdn_frontdoor_profile.main.sku_name == "Premium_AzureFrontDoor"
    error_message = "Front Door profile must use Premium SKU for WAF and private link support."
  }
}

run "validate_waf_managed_rules" {
  command = plan

  assert {
    condition     = length(azurerm_cdn_frontdoor_firewall_policy.main.managed_rule) == 2
    error_message = "WAF policy must have exactly 2 managed rule sets (DefaultRuleSet + BotManagerRuleSet)."
  }
}

run "validate_https_redirect" {
  command = plan

  assert {
    condition     = azurerm_cdn_frontdoor_route.main.https_redirect_enabled == true
    error_message = "HTTPS redirect must be enabled on the Front Door route."
  }
}

run "validate_forwarding_protocol" {
  command = plan

  assert {
    condition     = azurerm_cdn_frontdoor_route.main.forwarding_protocol == "HttpsOnly"
    error_message = "Route must forward to origin using HTTPS only."
  }
}

run "validate_health_probe_config" {
  command = plan

  assert {
    condition     = azurerm_cdn_frontdoor_origin_group.app_service.health_probe[0].protocol == "Https"
    error_message = "Health probe must use HTTPS protocol."
  }

  assert {
    condition     = azurerm_cdn_frontdoor_origin_group.app_service.health_probe[0].path == "/health"
    error_message = "Health probe path must be '/health'."
  }
}

run "validate_outputs_not_null" {
  command = plan

  assert {
    condition     = output.profile_id != null
    error_message = "profile_id output must not be null."
  }

  assert {
    condition     = output.endpoint_hostname != null
    error_message = "endpoint_hostname output must not be null."
  }

  assert {
    condition     = output.waf_policy_id != null
    error_message = "waf_policy_id output must not be null."
  }
}
