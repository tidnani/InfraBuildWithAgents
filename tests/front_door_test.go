package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestFrontDoorPlan(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("front_door")
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

module "front_door" {
  source              = %q
  profile_name        = "test-afd-001"
  endpoint_name       = "test-ep-001"
  resource_group_name = "test-rg-001"
  origins = [
    {
      name                   = "app-service-eastus"
      host_name              = "test-app-tt-001.azurewebsites.net"
      private_link_location  = "eastus"
      private_link_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/test-app-tt-001"
    }
  ]
  tags = {
    environment = "test"
  }
}

output "front_door_id" {
  value = module.front_door.front_door_id
}

output "front_door_profile_id" {
  value = module.front_door.front_door_profile_id
}

output "front_door_endpoint_hostname" {
  value = module.front_door.front_door_endpoint_hostname
}

output "waf_policy_id" {
  value = module.front_door.waf_policy_id
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	planExitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 2, planExitCode, "expected front door plan to have changes (exit code 2)")
}

func TestFrontDoorMultipleOrigins(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("front_door")
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

module "front_door" {
  source              = %q
  profile_name        = "test-afd-multi"
  endpoint_name       = "test-ep-multi"
  resource_group_name = "test-rg-001"
  origins = [
    {
      name                   = "app-service-eastus"
      host_name              = "test-app-eus.azurewebsites.net"
      private_link_location  = "eastus"
      private_link_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg-eus/providers/Microsoft.Web/sites/test-app-eus"
    },
    {
      name                   = "app-service-westus"
      host_name              = "test-app-wus.azurewebsites.net"
      private_link_location  = "westus2"
      private_link_target_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg-wus/providers/Microsoft.Web/sites/test-app-wus"
    }
  ]
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
	assert.Equal(t, 2, planExitCode, "expected front door multi-origin plan to have changes (exit code 2)")
}

func TestFrontDoorEmptyOriginsValidation(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("front_door")
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

module "front_door" {
  source              = %q
  profile_name        = "test-afd-empty"
  endpoint_name       = "test-ep-empty"
  resource_group_name = "test-rg-001"
  origins             = []
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	exitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 1, exitCode, "expected plan to fail when no origins are provided")
}
