package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestMonitoringPlan(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("monitoring")
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

module "monitoring" {
  source              = %q
  workspace_name      = "test-law-001"
  app_insights_name   = "test-ai-001"
  resource_group_name = "test-rg-001"
  location            = "eastus"
  action_group_name   = "test-ag-001"
  alert_email         = "test@example.com"
  app_service_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/test-app"
  app_service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-asp"
  http_5xx_threshold  = 10
  tags = {
    environment = "test"
  }
}

output "log_analytics_workspace_id" {
  value = module.monitoring.log_analytics_workspace_id
}

output "app_insights_id" {
  value = module.monitoring.app_insights_id
}

output "action_group_id" {
  value = module.monitoring.action_group_id
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	planExitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 2, planExitCode, "expected monitoring plan to have changes (exit code 2)")
}

func TestMonitoringEmailValidation(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("monitoring")
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

module "monitoring" {
  source              = %q
  workspace_name      = "test-law-invalid"
  app_insights_name   = "test-ai-invalid"
  resource_group_name = "test-rg-001"
  location            = "eastus"
  action_group_name   = "test-ag-invalid"
  alert_email         = "not-a-valid-email"
  app_service_id      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/test-app"
  app_service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/test-asp"
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	exitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 1, exitCode, "expected plan to fail with invalid email address")
}
