package test

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// moduleAbsPath returns the absolute path of a module relative to the test file.
func moduleAbsPath(moduleName string) string {
	_, filename, _, _ := runtime.Caller(0)
	testDir := filepath.Dir(filename)
	return filepath.Join(testDir, "..", "modules", moduleName)
}

// writeTerraformFixture writes a temporary main.tf fixture and returns the directory path.
func writeTerraformFixture(t *testing.T, content string) string {
	t.Helper()
	dir := t.TempDir()
	err := os.WriteFile(filepath.Join(dir, "main.tf"), []byte(content), 0600)
	require.NoError(t, err, "failed to write terraform fixture")
	return dir
}

func TestResourceGroupPlan(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("resource_group")
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

module "resource_group" {
  source   = %q
  name     = "test-rg-terratest-001"
  location = "eastus"
  tags = {
    environment = "test"
    managed-by  = "terraform"
  }
}

output "resource_group_name" {
  value = module.resource_group.name
}

output "resource_group_location" {
  value = module.resource_group.location
}

output "resource_group_id" {
  value = module.resource_group.id
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	planExitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 2, planExitCode, "expected plan to have changes (exit code 2), not an error (exit code 1)")
}

func TestResourceGroupValidation(t *testing.T) {
	t.Parallel()

	modulePath := moduleAbsPath("resource_group")

	// Test that an excessively long name fails validation
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

module "resource_group" {
  source   = %q
  name     = "this-name-is-way-too-long-for-a-valid-azure-resource-group-name-exceeding-ninety-characters-limit"
  location = "eastus"
}
`, modulePath)

	dir := writeTerraformFixture(t, fixture)

	options := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: dir,
		NoColor:      true,
	})

	exitCode := terraform.InitAndPlanWithExitCode(t, options)
	assert.Equal(t, 1, exitCode, "expected plan to fail (exit code 1) when resource group name exceeds 90 characters")
}
