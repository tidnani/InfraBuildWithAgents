package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAppServicePlan(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("app_service")
	fixture := fmt.Sprintf(`
terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
  skip_provider_registration = true
}

module "app_service" {
  source                         = %q
  app_name                       = "test-app-tt-001"
  resource_group_name            = "test-rg-001"
  location                       = "eastus"
  app_service_plan_name          = "test-asp-tt-001"
  subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/app-service-subnet"
  key_vault_uri                  = "https://test-kv-tt-001.vault.azure.net/"
  app_insights_connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://eastus-0.in.applicationinsights.azure.com/"
  app_insights_key               = "00000000-0000-0000-0000-000000000000"
  log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
  health_check_path              = "/health"
  allowed_front_door_header      = ""
  tags = {
    environment = "test"
  }
}

output "app_service_id" {
  value = module.app_service.app_service_id
}

output "app_service_name" {
  value = module.app_service.app_service_name
}

output "app_service_default_hostname" {
  value = module.app_service.app_service_default_hostname
}

output "app_service_plan_id" {
  value = module.app_service.app_service_plan_id
}

output "principal_id" {
  value = module.app_service.principal_id
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	planExitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 2, planExitCode, "expected app service plan to have changes (exit code 2)")
}

func TestAppServiceWithFrontDoorHeader(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("app_service")
	fixture := fmt.Sprintf(`
terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "00000000-0000-0000-0000-000000000000"
  skip_provider_registration = true
}

module "app_service" {
  source                         = %q
  app_name                       = "test-app-tt-002"
  resource_group_name            = "test-rg-001"
  location                       = "eastus"
  app_service_plan_name          = "test-asp-tt-002"
  subnet_id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/app-service-subnet"
  key_vault_uri                  = "https://test-kv-tt-001.vault.azure.net/"
  app_insights_connection_string = "InstrumentationKey=00000000-0000-0000-0000-000000000000;IngestionEndpoint=https://eastus-0.in.applicationinsights.azure.com/"
  app_insights_key               = "00000000-0000-0000-0000-000000000000"
  log_analytics_workspace_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-law"
  health_check_path              = "/health"
  allowed_front_door_header      = "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
  tags = {
    environment = "test"
  }
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	planExitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 2, planExitCode, "expected app service plan with Front Door header to have changes (exit code 2)")
}
