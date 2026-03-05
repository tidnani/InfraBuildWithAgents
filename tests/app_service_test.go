package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestAppServiceModule validates that the app_service module creates
// an App Service Plan and Web App with the correct configuration.
func TestAppServiceModule(t *testing.T) {
	t.Parallel()

	uniqueID := random.UniqueId()
	location := "eastus2"
	rgName := fmt.Sprintf("test-asp-rg-%s", uniqueID)

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

	// Create networking
	networkingOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/networking",
		Vars: map[string]interface{}{
			"vnet_name":                        fmt.Sprintf("test-vnet-asp-%s", uniqueID),
			"location":                         location,
			"resource_group_name":              rgName,
			"vnet_address_space":               []string{"10.150.0.0/16"},
			"app_service_subnet_name":          "app-service-integration",
			"app_service_subnet_prefixes":      []string{"10.150.1.0/24"},
			"private_endpoint_subnet_name":     "private-endpoints",
			"private_endpoint_subnet_prefixes": []string{"10.150.2.0/24"},
			"tags": map[string]string{"Environment": "test"},
		},
	})
	defer terraform.Destroy(t, networkingOptions)
	terraform.InitAndApply(t, networkingOptions)

	// Create monitoring
	monitoringOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/monitoring",
		Vars: map[string]interface{}{
			"log_analytics_workspace_name": fmt.Sprintf("tst-law-asp-%s", uniqueID),
			"app_insights_name":            fmt.Sprintf("tst-ai-asp-%s", uniqueID),
			"location":                     location,
			"resource_group_name":          rgName,
			"log_retention_days":           30,
			"app_insights_retention_days":  30,
			"daily_data_cap_gb":            1,
			"action_group_name":            fmt.Sprintf("tst-ag-asp-%s", uniqueID),
			"action_group_short_name":      "tstagasp",
			"alert_name_prefix":            fmt.Sprintf("tst-asp-%s", uniqueID),
			"alert_email_receivers":        []interface{}{},
			"create_dashboard":             false,
			"tags":                         map[string]string{"Environment": "test"},
		},
	})
	defer terraform.Destroy(t, monitoringOptions)
	terraform.InitAndApply(t, monitoringOptions)

	appServiceSubnetID := terraform.Output(t, networkingOptions, "app_service_subnet_id")
	peSubnetID := terraform.Output(t, networkingOptions, "private_endpoint_subnet_id")
	appServiceDNSZoneID := terraform.Output(t, networkingOptions, "app_service_private_dns_zone_id")
	workspaceID := terraform.Output(t, monitoringOptions, "log_analytics_workspace_id")
	appInsightsConnStr := terraform.Output(t, monitoringOptions, "app_insights_connection_string")

	// Create App Service
	appServiceOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../modules/app_service",
		Vars: map[string]interface{}{
			"app_service_plan_name":           fmt.Sprintf("tst-asp-%s", uniqueID),
			"web_app_name":                    fmt.Sprintf("tst-app-%s", uniqueID),
			"location":                        location,
			"resource_group_name":             rgName,
			"sku_name":                        "P1v3",
			"zone_balancing_enabled":          false,
			"worker_count":                    1,
			"vnet_integration_subnet_id":      appServiceSubnetID,
			"private_endpoint_subnet_id":      peSubnetID,
			"app_service_private_dns_zone_id": appServiceDNSZoneID,
			"log_analytics_workspace_id":      workspaceID,
			"app_insights_connection_string":  appInsightsConnStr,
			"health_check_path":               "/health",
			"node_version":                    "20-lts",
			"autoscale_min_capacity":          1,
			"autoscale_max_capacity":          3,
			"autoscale_default_capacity":      1,
			"tags": map[string]string{"Environment": "test"},
		},
	})
	defer terraform.Destroy(t, appServiceOptions)
	terraform.InitAndApply(t, appServiceOptions)

	// Validate outputs
	aspID := terraform.Output(t, appServiceOptions, "app_service_plan_id")
	webAppID := terraform.Output(t, appServiceOptions, "web_app_id")
	webAppName := terraform.Output(t, appServiceOptions, "web_app_name")
	defaultHostname := terraform.Output(t, appServiceOptions, "web_app_default_hostname")
	peID := terraform.Output(t, appServiceOptions, "private_endpoint_id")

	assert.NotEmpty(t, aspID)
	assert.NotEmpty(t, webAppID)
	assert.Contains(t, webAppName, "tst-app")
	assert.Contains(t, defaultHostname, "azurewebsites.net")
	assert.NotEmpty(t, peID)
}
