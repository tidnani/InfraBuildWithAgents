mock_provider "azurerm" {}

run "valid_key_vault" {
  command = plan

  module {
    source = "../modules/key_vault"
  }

  variables {
    key_vault_name      = "kv-test-001"
    location            = "eastus"
    resource_group_name = "rg-test-001"
    tenant_id           = "00000000-0000-0000-0000-000000000000"
    tags                = { environment = "test" }
  }

  assert {
    condition     = azurerm_key_vault.this.name == "kv-test-001"
    error_message = "Key Vault name should match input variable"
  }

  assert {
    condition     = azurerm_key_vault.this.enable_rbac_authorization == true
    error_message = "Key Vault should use RBAC authorization"
  }

  assert {
    condition     = azurerm_key_vault.this.purge_protection_enabled == true
    error_message = "Purge protection should be enabled by default"
  }

  assert {
    condition     = azurerm_key_vault.this.soft_delete_retention_days == 90
    error_message = "Soft delete retention should default to 90 days"
  }
}

run "invalid_key_vault_name_too_short" {
  command = plan

  module {
    source = "../modules/key_vault"
  }

  variables {
    key_vault_name      = "kv"
    location            = "eastus"
    resource_group_name = "rg-test-001"
    tenant_id           = "00000000-0000-0000-0000-000000000000"
  }

  expect_failures = [var.key_vault_name]
}

run "invalid_sku_name" {
  command = plan

  module {
    source = "../modules/key_vault"
  }

  variables {
    key_vault_name      = "kv-test-001"
    location            = "eastus"
    resource_group_name = "rg-test-001"
    tenant_id           = "00000000-0000-0000-0000-000000000000"
    sku_name            = "enterprise"
  }

  expect_failures = [var.sku_name]
}
