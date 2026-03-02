mock_provider "azurerm" {}

run "valid_private_endpoints_empty" {
  command = plan

  module {
    source = "../modules/private_endpoints"
  }

  variables {
    resource_group_name = "rg-test-001"
    location            = "eastus"
    virtual_network_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    create_dns_zones    = true
    tags                = { environment = "test" }
  }

  assert {
    condition     = length(azurerm_private_endpoint.this) == 0
    error_message = "No private endpoints should be created when none are specified"
  }

  assert {
    condition     = length(azurerm_private_dns_zone.sql) == 1
    error_message = "SQL private DNS zone should be created when create_dns_zones is true"
  }

  assert {
    condition     = azurerm_private_dns_zone.sql[0].name == "privatelink.database.windows.net"
    error_message = "SQL DNS zone should use correct private link domain"
  }
}

run "dns_zones_not_created_when_disabled" {
  command = plan

  module {
    source = "../modules/private_endpoints"
  }

  variables {
    resource_group_name = "rg-test-001"
    location            = "eastus"
    virtual_network_id  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test"
    create_dns_zones    = false
  }

  assert {
    condition     = length(azurerm_private_dns_zone.sql) == 0
    error_message = "No DNS zones should be created when create_dns_zones is false"
  }
}
