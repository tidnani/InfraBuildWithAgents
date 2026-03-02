mock_provider "azurerm" {}

run "valid_networking" {
  command = plan

  module {
    source = "../modules/networking"
  }

  variables {
    vnet_name           = "vnet-test-001"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = "rg-test-001"
    tags                = { environment = "test" }

    subnets = {
      app_service_subnet = {
        address_prefix = "10.0.1.0/24"
        service_delegation = {
          name    = "Microsoft.Web/serverFarms"
          actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
      }
      private_endpoint_subnet = {
        address_prefix     = "10.0.2.0/24"
        service_delegation = null
      }
    }
  }

  assert {
    condition     = azurerm_virtual_network.this.name == "vnet-test-001"
    error_message = "VNet name should match input variable"
  }

  assert {
    condition     = azurerm_virtual_network.this.address_space[0] == "10.0.0.0/16"
    error_message = "VNet address space should match input variable"
  }

  assert {
    condition     = length(azurerm_subnet.this) == 2
    error_message = "Two subnets should be created"
  }

  assert {
    condition     = length(azurerm_network_security_group.this) == 2
    error_message = "Two NSGs should be created"
  }
}
