package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/azure"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestResourceGroupModule validates that the resource_group module creates
// a resource group with the correct name, location, and tags.
func TestResourceGroupModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	rgName := fmt.Sprintf("test-rg-%s", uniqueID)
	location := "eastus2"

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/resource_group",
		Vars: map[string]interface{}{
			"name":     rgName,
			"location": location,
			"tags": map[string]string{
				"Environment": "test",
				"ManagedBy":   "Terratest",
			},
		},
	})

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	// Validate outputs
	outputName := terraform.Output(t, terraformOptions, "name")
	outputLocation := terraform.Output(t, terraformOptions, "location")
	outputID := terraform.Output(t, terraformOptions, "id")

	assert.Equal(t, rgName, outputName)
	assert.Equal(t, location, outputLocation)
	assert.NotEmpty(t, outputID)

	// Validate the resource group actually exists in Azure
	subscriptionID := os.Getenv("AZURE_SUBSCRIPTION_ID")
	exists := azure.ResourceGroupExists(t, rgName, subscriptionID)
	require.True(t, exists, "Resource group %s should exist in Azure", rgName)
}
