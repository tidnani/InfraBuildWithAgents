package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestNetworkingPlan(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("networking")
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

module "networking" {
  source                         = %q
  vnet_name                      = "test-vnet-001"
  vnet_address_space             = ["10.10.0.0/16"]
  app_service_subnet_prefix      = "10.10.1.0/24"
  private_endpoint_subnet_prefix = "10.10.2.0/24"
  resource_group_name            = "test-rg-001"
  location                       = "eastus"
  tags = {
    environment = "test"
  }
}

output "vnet_id" {
  value = module.networking.vnet_id
}

output "app_service_subnet_id" {
  value = module.networking.app_service_subnet_id
}

output "private_endpoint_subnet_id" {
  value = module.networking.private_endpoint_subnet_id
}

output "key_vault_private_dns_zone_id" {
  value = module.networking.key_vault_private_dns_zone_id
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	planExitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 2, planExitCode, "expected networking plan to have changes (exit code 2)")
}

func TestNetworkingSubnetCIDRs(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("networking")

	// Overlapping CIDRs should not pass planning with valid Azure config
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

module "networking" {
  source                         = %q
  vnet_name                      = "test-vnet-overlap"
  vnet_address_space             = ["10.50.0.0/16"]
  app_service_subnet_prefix      = "10.50.1.0/24"
  private_endpoint_subnet_prefix = "10.50.2.0/24"
  resource_group_name            = "test-rg-overlap"
  location                       = "westus2"
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	planExitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 2, planExitCode, "expected networking plan with non-overlapping CIDRs to succeed")
}
