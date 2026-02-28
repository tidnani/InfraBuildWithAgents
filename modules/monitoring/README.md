# Monitoring Module

## Overview

This module provisions Azure Monitor resources for the Mission Critical App Service architecture, providing end-to-end observability, alerting, and a centralised operations dashboard.

## Resources Created

| Resource | Description |
|---|---|
| `azurerm_log_analytics_workspace` | Centralised log store for all diagnostic settings |
| `azurerm_application_insights` | Workspace-based Application Insights for APM telemetry |
| `azurerm_monitor_action_group` | Email action group for alert notifications |
| `azurerm_monitor_metric_alert` (availability) | Fires when availability < 99% over 5 minutes |
| `azurerm_monitor_metric_alert` (response_time) | Fires when avg response time > 2 s over 5 minutes |
| `azurerm_monitor_metric_alert` (error_rate) | Fires when failed request count exceeds threshold |
| `azurerm_portal_dashboard` | Operations dashboard with request and error charts |

## WAF Alignment

- **Reliability**: Proactive alerting on availability and error rate ensures fast incident detection.
- **Operational Excellence**: Workspace-based Application Insights enables cross-resource queries; dashboard provides a single pane of glass.
- **Performance Efficiency**: Response-time alert catches latency regressions before they impact users.
- **Cost Optimization**: Configurable retention period balances observability with storage costs.

## Usage

```hcl
module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name   = azurerm_resource_group.main.name
  location              = "eastus2"
  name_prefix           = "myapp-prod"
  retention_days        = 90
  alert_email_addresses = ["ops@example.com"]
  tags                  = { environment = "prod" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `resource_group_name` | Resource group name | `string` | — | yes |
| `location` | Azure region | `string` | — | yes |
| `name_prefix` | Resource name prefix | `string` | — | yes |
| `retention_days` | Log retention in days (30–730) | `number` | `90` | no |
| `alert_email_addresses` | Alert notification emails | `list(string)` | `[]` | no |
| `error_rate_threshold` | Failed request count threshold | `number` | `10` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `log_analytics_workspace_id` | Log Analytics Workspace resource ID |
| `app_insights_connection_string` | Application Insights connection string (sensitive) |
| `app_insights_instrumentation_key` | Application Insights instrumentation key (sensitive) |
| `action_group_id` | Critical alert action group ID |
