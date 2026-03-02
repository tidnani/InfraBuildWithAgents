mock_provider "azurerm" {}

run "valid_redis_cache" {
  command = plan

  module {
    source = "../modules/redis_cache"
  }

  variables {
    redis_cache_name    = "redis-test-001"
    location            = "eastus"
    resource_group_name = "rg-test-001"
    tags                = { environment = "test" }
  }

  assert {
    condition     = azurerm_redis_cache.this.name == "redis-test-001"
    error_message = "Redis Cache name should match input variable"
  }

  assert {
    condition     = azurerm_redis_cache.this.minimum_tls_version == "1.2"
    error_message = "Minimum TLS version should be 1.2"
  }

  assert {
    condition     = azurerm_redis_cache.this.public_network_access_enabled == false
    error_message = "Public network access should be disabled"
  }
}

run "invalid_sku_name" {
  command = plan

  module {
    source = "../modules/redis_cache"
  }

  variables {
    redis_cache_name    = "redis-test-001"
    location            = "eastus"
    resource_group_name = "rg-test-001"
    sku_name            = "Enterprise"
  }

  expect_failures = [var.sku_name]
}
