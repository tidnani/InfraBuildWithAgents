# App Service module tests
# Uses Terraform's native testing framework (terraform test)

variables {
  resource_group_name              = "test-app-rg"
  location                         = "eastus2"
  name_prefix                      = "test-app"
  sku_name                         = "P3v3"
  plan_capacity                    = 3
  autoscale_min_count              = 2
  autoscale_max_count              = 10
  vnet_integration_subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/snet-appservice"
  private_endpoint_subnet_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/snet-pe"
  private_dns_zone_id              = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.azurewebsites.net"
  key_vault_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
  sql_connection_string_uri        = "https://test-kv.vault.azure.net/secrets/sql-connection-string"
  redis_connection_string_uri      = "https://test-kv.vault.azure.net/secrets/redis-connection-string"
  log_analytics_workspace_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
  app_insights_connection_string   = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
  app_insights_instrumentation_key = "00000000-0000-0000-0000-000000000000"
  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}

run "validate_sku_is_premium_v3" {
  command = plan

  assert {
    condition     = can(regex("^P[0-9]v3$", var.sku_name))
    error_message = "App Service Plan SKU must be Premium v3 tier."
  }
}

run "validate_https_only" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.main.https_only == true
    error_message = "App Service must enforce HTTPS-only."
  }
}

run "validate_public_access_disabled" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.main.public_network_access_enabled == false
    error_message = "App Service public network access must be disabled."
  }
}

run "validate_managed_identity" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.main.identity[0].type == "SystemAssigned"
    error_message = "App Service must use system-assigned managed identity."
  }
}

run "validate_always_on" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.main.site_config[0].always_on == true
    error_message = "App Service always_on must be enabled."
  }
}

run "validate_ftps_disabled" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.main.site_config[0].ftps_state == "Disabled"
    error_message = "App Service FTPS must be disabled."
  }
}

run "validate_health_check_path" {
  command = plan

  assert {
    condition     = azurerm_linux_web_app.main.site_config[0].health_check_path == "/health"
    error_message = "App Service health check path must be '/health'."
  }
}

run "validate_zone_balancing" {
  command = plan

  assert {
    condition     = azurerm_service_plan.main.zone_balancing_enabled == true
    error_message = "App Service Plan must have zone balancing enabled."
  }
}

run "validate_autoscale_rules" {
  command = plan

  assert {
    condition     = azurerm_monitor_autoscale_setting.app_service.profile[0].capacity[0].minimum == var.autoscale_min_count
    error_message = "Autoscale minimum capacity must match the variable."
  }

  assert {
    condition     = azurerm_monitor_autoscale_setting.app_service.profile[0].capacity[0].maximum == var.autoscale_max_count
    error_message = "Autoscale maximum capacity must match the variable."
  }
}

run "validate_key_vault_reference_format" {
  command = plan

  assert {
    condition     = can(regex("^@Microsoft.KeyVault\\(SecretUri=.+\\)$", azurerm_linux_web_app.main.app_settings["ConnectionStrings__DefaultConnection"]))
    error_message = "SQL connection string must use Key Vault reference format."
  }

  assert {
    condition     = can(regex("^@Microsoft.KeyVault\\(SecretUri=.+\\)$", azurerm_linux_web_app.main.app_settings["ConnectionStrings__Redis"]))
    error_message = "Redis connection string must use Key Vault reference format."
  }
}

run "validate_outputs" {
  command = plan

  assert {
    condition     = output.app_service_id != null
    error_message = "app_service_id output must not be null."
  }

  assert {
    condition     = output.app_service_default_hostname != null
    error_message = "app_service_default_hostname output must not be null."
  }

  assert {
    condition     = output.app_service_principal_id != null
    error_message = "app_service_principal_id output must not be null."
  }
}
