mock_provider "azurerm" {}

run "valid_front_door" {
  command = plan

  module {
    source = "../modules/front_door"
  }

  variables {
    front_door_name     = "afd-test-001"
    resource_group_name = "rg-test-001"
    waf_policy_name     = "wafpolicytestdev001"
    tags                = { environment = "test" }

    origins = [
      {
        name               = "app-origin-primary"
        host_name          = "app-test-001.azurewebsites.net"
        origin_host_header = "app-test-001.azurewebsites.net"
        priority           = 1
        weight             = 1000
      }
    ]
  }

  assert {
    condition     = azurerm_cdn_frontdoor_profile.this.name == "afd-test-001"
    error_message = "Front Door profile name should match input variable"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_profile.this.sku_name == "Premium_AzureFrontDoor"
    error_message = "Front Door should use Premium SKU"
  }

  assert {
    condition     = azurerm_cdn_frontdoor_firewall_policy.this.mode == "Prevention"
    error_message = "WAF policy should be in Prevention mode"
  }

  assert {
    condition     = length(azurerm_cdn_frontdoor_origin.this) == 1
    error_message = "One origin should be created"
  }
}
