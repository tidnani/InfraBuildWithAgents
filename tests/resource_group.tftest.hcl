mock_provider "azurerm" {}

run "valid_resource_group" {
  command = plan

  module {
    source = "../modules/resource_group"
  }

  variables {
    name     = "rg-test-001"
    location = "eastus"
    tags     = { environment = "test" }
  }

  assert {
    condition     = azurerm_resource_group.this.name == "rg-test-001"
    error_message = "Resource group name should match input variable"
  }

  assert {
    condition     = azurerm_resource_group.this.location == "eastus"
    error_message = "Resource group location should match input variable"
  }

  assert {
    condition     = azurerm_resource_group.this.tags["managed_by"] == "terraform"
    error_message = "Resource group should have managed_by=terraform tag"
  }

  assert {
    condition     = azurerm_resource_group.this.tags["environment"] == "test"
    error_message = "Resource group should have environment=test tag"
  }
}

run "default_tags_applied" {
  command = plan

  module {
    source = "../modules/resource_group"
  }

  variables {
    name     = "rg-test-002"
    location = "westus2"
    tags     = {}
  }

  assert {
    condition     = azurerm_resource_group.this.tags["managed_by"] == "terraform"
    error_message = "Default managed_by tag should always be applied"
  }
}
