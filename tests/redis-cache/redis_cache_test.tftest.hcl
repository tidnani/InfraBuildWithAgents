# Redis Cache module tests
# Uses Terraform's native testing framework (terraform test)

variables {
  resource_group_name        = "test-redis-rg"
  location                   = "eastus2"
  name_prefix                = "test-redis"
  capacity                   = 1
  family                     = "P"
  sku_name                   = "Premium"
  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/snet-pe"
  private_dns_zone_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.redis.cache.windows.net"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
  key_vault_id               = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/test-kv"
  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}

run "validate_public_access_disabled" {
  command = plan

  assert {
    condition     = azurerm_redis_cache.main.public_network_access_enabled == false
    error_message = "Redis Cache public network access must be disabled."
  }
}

run "validate_minimum_tls" {
  command = plan

  assert {
    condition     = azurerm_redis_cache.main.minimum_tls_version == "1.2"
    error_message = "Redis Cache minimum TLS version must be 1.2."
  }
}

run "validate_authentication_enabled" {
  command = plan

  assert {
    condition     = azurerm_redis_cache.main.redis_configuration[0].enable_authentication == true
    error_message = "Redis Cache authentication must be enabled."
  }
}

run "validate_sku_is_premium" {
  command = plan

  assert {
    condition     = var.sku_name == "Premium"
    error_message = "Redis Cache should use Premium SKU for zone redundancy and private endpoints."
  }
}

run "validate_eviction_policy" {
  command = plan

  assert {
    condition     = azurerm_redis_cache.main.redis_configuration[0].maxmemory_policy == "allkeys-lru"
    error_message = "Redis maxmemory policy should be 'allkeys-lru'."
  }
}

run "validate_maintenance_window" {
  command = plan

  assert {
    condition     = azurerm_redis_cache.main.patch_schedule[0].day_of_week == "Sunday"
    error_message = "Redis maintenance window should be set to Sunday."
  }
}

run "validate_outputs" {
  command = plan

  assert {
    condition     = output.redis_id != null
    error_message = "redis_id output must not be null."
  }

  assert {
    condition     = output.redis_hostname != null
    error_message = "redis_hostname output must not be null."
  }

  assert {
    condition     = output.connection_string_key_vault_uri != null
    error_message = "connection_string_key_vault_uri output must not be null."
  }
}
