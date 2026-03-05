package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestMonitoringModule validates that the monitoring module creates
// the Log Analytics workspace, Application Insights, and action group.
func TestMonitoringModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	location := "eastus2"
	rgName := fmt.Sprintf("test-mon-rg-%s", uniqueID)

	// Create resource group first
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

	monitoringOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/monitoring",
		Vars: map[string]interface{}{
			"log_analytics_workspace_name": fmt.Sprintf("test-law-%s", uniqueID),
			"app_insights_name":            fmt.Sprintf("test-ai-%s", uniqueID),
			"location":                     location,
			"resource_group_name":          rgName,
			"log_retention_days":           30,
			"app_insights_retention_days":  30,
			"daily_data_cap_gb":            5,
			"action_group_name":            fmt.Sprintf("test-ag-%s", uniqueID),
			"action_group_short_name":      "testag",
			"alert_name_prefix":            fmt.Sprintf("test-%s", uniqueID),
			"alert_email_receivers":        []interface{}{},
			"create_dashboard":             false,
			"tags": map[string]string{
				"Environment": "test",
				"ManagedBy":   "Terratest",
			},
		},
	})
	defer terraform.Destroy(t, monitoringOptions)
	terraform.InitAndApply(t, monitoringOptions)

	// Validate outputs
	workspaceID := terraform.Output(t, monitoringOptions, "log_analytics_workspace_id")
	appInsightsID := terraform.Output(t, monitoringOptions, "app_insights_id")
	actionGroupID := terraform.Output(t, monitoringOptions, "action_group_id")
	connectionString := terraform.Output(t, monitoringOptions, "app_insights_connection_string")

	assert.NotEmpty(t, workspaceID)
	assert.NotEmpty(t, appInsightsID)
	assert.NotEmpty(t, actionGroupID)
	assert.NotEmpty(t, connectionString)
	assert.Contains(t, connectionString, "InstrumentationKey")
}
