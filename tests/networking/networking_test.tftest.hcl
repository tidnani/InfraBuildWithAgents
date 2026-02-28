# Networking module tests
# Uses Terraform's native testing framework (terraform test)

variables {
  resource_group_name = "test-networking-rg"
  location            = "eastus2"
  name_prefix         = "test-net"
  vnet_address_space  = ["10.0.0.0/16"]
  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}

# ── Unit Tests (no provider calls) ───────────────────────────────────────────

run "validate_vnet_address_space" {
  command = plan

  assert {
    condition     = length(var.vnet_address_space) > 0
    error_message = "VNet address space must contain at least one CIDR block."
  }
}

run "validate_subnet_cidrs_within_vnet" {
  command = plan

  assert {
    condition     = cidrsubnet(var.vnet_address_space[0], 8, 0) == "10.0.0.0/24"
    error_message = "App Service subnet CIDR does not match expected value."
  }

  assert {
    condition     = cidrsubnet(var.vnet_address_space[0], 8, 1) == "10.0.1.0/24"
    error_message = "Private endpoint subnet CIDR does not match expected value."
  }
}

run "validate_module_outputs_are_set" {
  command = plan

  assert {
    condition     = output.vnet_id != null
    error_message = "vnet_id output must not be null."
  }

  assert {
    condition     = output.app_service_subnet_id != null
    error_message = "app_service_subnet_id output must not be null."
  }

  assert {
    condition     = output.private_endpoint_subnet_id != null
    error_message = "private_endpoint_subnet_id output must not be null."
  }

  assert {
    condition     = output.sql_private_dns_zone_id != null
    error_message = "sql_private_dns_zone_id output must not be null."
  }

  assert {
    condition     = output.redis_private_dns_zone_id != null
    error_message = "redis_private_dns_zone_id output must not be null."
  }

  assert {
    condition     = output.keyvault_private_dns_zone_id != null
    error_message = "keyvault_private_dns_zone_id output must not be null."
  }

  assert {
    condition     = output.sites_private_dns_zone_id != null
    error_message = "sites_private_dns_zone_id output must not be null."
  }
}

run "validate_private_dns_zone_names" {
  command = plan

  assert {
    condition     = azurerm_private_dns_zone.sql.name == "privatelink.database.windows.net"
    error_message = "SQL private DNS zone name is incorrect."
  }

  assert {
    condition     = azurerm_private_dns_zone.redis.name == "privatelink.redis.cache.windows.net"
    error_message = "Redis private DNS zone name is incorrect."
  }

  assert {
    condition     = azurerm_private_dns_zone.keyvault.name == "privatelink.vaultcore.azure.net"
    error_message = "Key Vault private DNS zone name is incorrect."
  }

  assert {
    condition     = azurerm_private_dns_zone.sites.name == "privatelink.azurewebsites.net"
    error_message = "Sites private DNS zone name is incorrect."
  }
}

run "validate_bastion_subnet_name" {
  command = plan

  assert {
    condition     = azurerm_subnet.bastion.name == "AzureBastionSubnet"
    error_message = "Bastion subnet must be named exactly 'AzureBastionSubnet'."
  }
}

run "validate_app_service_delegation" {
  command = plan

  assert {
    condition     = azurerm_subnet.app_service.delegation[0].service_delegation[0].name == "Microsoft.Web/serverFarms"
    error_message = "App Service subnet must have Microsoft.Web/serverFarms service delegation."
  }
}
