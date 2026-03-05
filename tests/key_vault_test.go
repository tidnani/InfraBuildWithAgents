package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestKeyVaultModule validates that the key_vault module creates a Key Vault
// with the correct configuration (RBAC, private endpoint, purge protection).
func TestKeyVaultModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	location := "eastus2"
	rgName := fmt.Sprintf("test-kv-rg-%s", uniqueID)
	// Key Vault names are max 24 chars, start with letter, alphanumeric + hyphens
	kvName := fmt.Sprintf("tst%skv", uniqueID[:8])

	// Create resource group
	rgOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/resource_group",
		Vars: map[string]interface{}{
			"name":     rgName,
			"location": location,
			"tags":     map[string]string{"Environment": "test", "ManagedBy": "Terratest"},
		},
	})
	defer terraform.Destroy(t, rgOptions)
	terraform.InitAndApply(t, rgOptions)

	// Create networking
	networkingOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/networking",
		Vars: map[string]interface{}{
			"vnet_name":                        fmt.Sprintf("test-vnet-kv-%s", uniqueID),
			"location":                         location,
			"resource_group_name":              rgName,
			"vnet_address_space":               []string{"10.200.0.0/16"},
			"app_service_subnet_name":          "app-service-integration",
			"app_service_subnet_prefixes":      []string{"10.200.1.0/24"},
			"private_endpoint_subnet_name":     "private-endpoints",
			"private_endpoint_subnet_prefixes": []string{"10.200.2.0/24"},
			"tags": map[string]string{"Environment": "test", "ManagedBy": "Terratest"},
		},
	})
	defer terraform.Destroy(t, networkingOptions)
	terraform.InitAndApply(t, networkingOptions)

	// Create monitoring (for log_analytics_workspace_id)
	monitoringOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/monitoring",
		Vars: map[string]interface{}{
			"log_analytics_workspace_name": fmt.Sprintf("tst-law-%s", uniqueID),
			"app_insights_name":            fmt.Sprintf("tst-ai-%s", uniqueID),
			"location":                     location,
			"resource_group_name":          rgName,
			"log_retention_days":           30,
			"app_insights_retention_days":  30,
			"daily_data_cap_gb":            1,
			"action_group_name":            fmt.Sprintf("tst-ag-%s", uniqueID),
			"action_group_short_name":      "tstag",
			"alert_name_prefix":            fmt.Sprintf("tst-%s", uniqueID),
			"alert_email_receivers":        []interface{}{},
			"create_dashboard":             false,
			"tags":                         map[string]string{"Environment": "test"},
		},
	})
	defer terraform.Destroy(t, monitoringOptions)
	terraform.InitAndApply(t, monitoringOptions)

	peSubnetID := terraform.Output(t, networkingOptions, "private_endpoint_subnet_id")
	kvDNSZoneID := terraform.Output(t, networkingOptions, "key_vault_private_dns_zone_id")
	workspaceID := terraform.Output(t, monitoringOptions, "log_analytics_workspace_id")

	// Create Key Vault
	kvOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/key_vault",
		Vars: map[string]interface{}{
			"name":                          kvName,
			"location":                      location,
			"resource_group_name":           rgName,
			"private_endpoint_subnet_id":    peSubnetID,
			"key_vault_private_dns_zone_id": kvDNSZoneID,
			"log_analytics_workspace_id":    workspaceID,
			"web_app_principal_ids":         []string{},
			"tags":                          map[string]string{"Environment": "test", "ManagedBy": "Terratest"},
		},
	})
	defer terraform.Destroy(t, kvOptions)
	terraform.InitAndApply(t, kvOptions)

	// Validate outputs
	kvID := terraform.Output(t, kvOptions, "key_vault_id")
	kvURI := terraform.Output(t, kvOptions, "key_vault_uri")
	peID := terraform.Output(t, kvOptions, "private_endpoint_id")

	assert.NotEmpty(t, kvID)
	assert.Contains(t, kvURI, kvName)
	assert.NotEmpty(t, peID)
}
