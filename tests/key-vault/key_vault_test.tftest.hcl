# Key Vault module tests
# Uses Terraform's native testing framework (terraform test)

variables {
  resource_group_name        = "test-kv-rg"
  location                   = "eastus2"
  name_prefix                = "test-kv"
  sku_name                   = "premium"
  private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/snet-pe"
  private_dns_zone_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"
  log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
  sql_admin_password         = "P@ssw0rd123!"
  tags = {
    environment = "test"
    managed_by  = "terraform"
  }
}

run "validate_rbac_authorization_enabled" {
  command = plan

  assert {
    condition     = azurerm_key_vault.main.enable_rbac_authorization == true
    error_message = "Key Vault must use RBAC authorization."
  }
}

run "validate_public_access_disabled" {
  command = plan

  assert {
    condition     = azurerm_key_vault.main.public_network_access_enabled == false
    error_message = "Key Vault public network access must be disabled."
  }
}

run "validate_soft_delete_retention" {
  command = plan

  assert {
    condition     = azurerm_key_vault.main.soft_delete_retention_days == 90
    error_message = "Key Vault soft delete retention must be 90 days."
  }
}

run "validate_purge_protection_enabled" {
  command = plan

  assert {
    condition     = azurerm_key_vault.main.purge_protection_enabled == true
    error_message = "Key Vault purge protection must be enabled."
  }
}

run "validate_network_acls_default_deny" {
  command = plan

  assert {
    condition     = azurerm_key_vault.main.network_acls[0].default_action == "Deny"
    error_message = "Key Vault network ACL default action must be 'Deny'."
  }
}

run "validate_network_acls_bypass" {
  command = plan

  assert {
    condition     = azurerm_key_vault.main.network_acls[0].bypass == "AzureServices"
    error_message = "Key Vault network ACL must allow bypass for AzureServices."
  }
}

run "validate_outputs" {
  command = plan

  assert {
    condition     = output.key_vault_id != null
    error_message = "key_vault_id output must not be null."
  }

  assert {
    condition     = output.key_vault_uri != null
    error_message = "key_vault_uri output must not be null."
  }

  assert {
    condition     = output.sql_admin_password_secret_uri != null
    error_message = "sql_admin_password_secret_uri output must not be null."
  }
}
