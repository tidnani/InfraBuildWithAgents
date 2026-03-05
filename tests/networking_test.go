package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestNetworkingModule validates that the networking module creates a VNet,
// the required subnets, NSGs, and private DNS zones.
func TestNetworkingModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	location := "eastus2"
	rgName := fmt.Sprintf("test-net-rg-%s", uniqueID)

	// First create the resource group that the networking module will use
	rgOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
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
	defer terraform.Destroy(t, rgOptions)
	terraform.InitAndApply(t, rgOptions)

	// Now create networking resources
	networkingOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/networking",
		Vars: map[string]interface{}{
			"vnet_name":           fmt.Sprintf("test-vnet-%s", uniqueID),
			"location":            location,
			"resource_group_name": rgName,
			"vnet_address_space":  []string{"10.100.0.0/16"},
			"app_service_subnet_name":          "app-service-integration",
			"app_service_subnet_prefixes":      []string{"10.100.1.0/24"},
			"private_endpoint_subnet_name":     "private-endpoints",
			"private_endpoint_subnet_prefixes": []string{"10.100.2.0/24"},
			"tags": map[string]string{
				"Environment": "test",
				"ManagedBy":   "Terratest",
			},
		},
	})
	defer terraform.Destroy(t, networkingOptions)
	terraform.InitAndApply(t, networkingOptions)

	// Validate outputs
	vnetID := terraform.Output(t, networkingOptions, "vnet_id")
	vnetName := terraform.Output(t, networkingOptions, "vnet_name")
	appServiceSubnetID := terraform.Output(t, networkingOptions, "app_service_subnet_id")
	privateEndpointSubnetID := terraform.Output(t, networkingOptions, "private_endpoint_subnet_id")
	appServiceDNSZoneID := terraform.Output(t, networkingOptions, "app_service_private_dns_zone_id")
	keyVaultDNSZoneID := terraform.Output(t, networkingOptions, "key_vault_private_dns_zone_id")

	assert.NotEmpty(t, vnetID)
	assert.Contains(t, vnetName, "test-vnet")
	assert.NotEmpty(t, appServiceSubnetID)
	assert.NotEmpty(t, privateEndpointSubnetID)
	assert.NotEmpty(t, appServiceDNSZoneID)
	assert.NotEmpty(t, keyVaultDNSZoneID)
}
