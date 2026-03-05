package test

import (
	"fmt"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestFrontDoorModule validates that the front_door module creates a Front Door
// profile, endpoint, WAF policy, origin group, and route.
func TestFrontDoorModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	location := "eastus2"
	rgName := fmt.Sprintf("test-afd-rg-%s", uniqueID)
	// WAF policy names must be alphanumeric, max 128 chars
	wafName := fmt.Sprintf("testwaf%s", strings.ToLower(uniqueID))

	// Create resource group
	rgOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/resource_group",
		Vars: map[string]interface{}{
			"name":     rgName,
			"location": location,
			"tags":     map[string]string{"Environment": "test"},
		},
	})
	defer terraform.Destroy(t, rgOptions)
	terraform.InitAndApply(t, rgOptions)

	// Create monitoring (for log analytics workspace)
	monitoringOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/monitoring",
		Vars: map[string]interface{}{
			"log_analytics_workspace_name": fmt.Sprintf("tst-law-afd-%s", uniqueID),
			"app_insights_name":            fmt.Sprintf("tst-ai-afd-%s", uniqueID),
			"location":                     location,
			"resource_group_name":          rgName,
			"log_retention_days":           30,
			"app_insights_retention_days":  30,
			"daily_data_cap_gb":            1,
			"action_group_name":            fmt.Sprintf("tst-ag-afd-%s", uniqueID),
			"action_group_short_name":      "tstagafd",
			"alert_name_prefix":            fmt.Sprintf("tst-afd-%s", uniqueID),
			"alert_email_receivers":        []interface{}{},
			"create_dashboard":             false,
			"tags":                         map[string]string{"Environment": "test"},
		},
	})
	defer terraform.Destroy(t, monitoringOptions)
	terraform.InitAndApply(t, monitoringOptions)

	workspaceID := terraform.Output(t, monitoringOptions, "log_analytics_workspace_id")

	// Create Front Door
	afdOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/front_door",
		Vars: map[string]interface{}{
			"front_door_name":            fmt.Sprintf("tst-afd-%s", uniqueID),
			"resource_group_name":        rgName,
			"sku_name":                   "Premium_AzureFrontDoor",
			"endpoint_name":              fmt.Sprintf("tst-ep-%s", uniqueID),
			"waf_policy_name":            wafName,
			"waf_mode":                   "Detection",
			"origin_group_name":          fmt.Sprintf("tst-og-%s", uniqueID),
			"health_probe_path":          "/health",
			"log_analytics_workspace_id": workspaceID,
			"origins": map[string]interface{}{
				"test-origin": map[string]interface{}{
					"host_name":                "www.example.com",
					"priority":                 1,
					"weight":                   1000,
					"private_link_resource_id": nil,
					"private_link_location":    nil,
				},
			},
			"tags": map[string]string{"Environment": "test"},
		},
	})
	defer terraform.Destroy(t, afdOptions)
	terraform.InitAndApply(t, afdOptions)

	// Validate outputs
	afdID := terraform.Output(t, afdOptions, "front_door_id")
	endpointHostname := terraform.Output(t, afdOptions, "endpoint_hostname")
	endpointID := terraform.Output(t, afdOptions, "endpoint_id")
	wafPolicyID := terraform.Output(t, afdOptions, "waf_policy_id")

	assert.NotEmpty(t, afdID)
	assert.Contains(t, endpointHostname, "azurefd.net")
	assert.NotEmpty(t, endpointID)
	assert.NotEmpty(t, wafPolicyID)
}
