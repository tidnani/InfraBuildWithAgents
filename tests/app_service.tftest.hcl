mock_provider "azurerm" {}

run "valid_app_service" {
  command = plan

  module {
    source = "../modules/app_service"
  }

  variables {
    app_service_plan_name          = "asp-test-001"
    app_service_name               = "app-test-001"
    location                       = "eastus"
    resource_group_name            = "rg-test-001"
    subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/app_service_subnet"
    app_insights_connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000"
    tags                           = { environment = "test" }
  }

  assert {
    condition     = azurerm_service_plan.this.name == "asp-test-001"
    error_message = "App Service Plan name should match input variable"
  }

  assert {
    condition     = azurerm_service_plan.this.os_type == "Linux"
    error_message = "App Service Plan should be Linux"
  }

  assert {
    condition     = azurerm_linux_web_app.this.https_only == true
    error_message = "App Service should be HTTPS only"
  }

  assert {
    condition     = azurerm_linux_web_app.this.identity[0].type == "SystemAssigned"
    error_message = "App Service should have system-assigned managed identity"
  }
}
