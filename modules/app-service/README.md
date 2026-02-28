# App Service Module

## Overview

This module provisions an Azure App Service (Premium v3, Linux) with VNet integration, private endpoint, Key Vault secret references, auto-scaling rules, health checks, and full diagnostic logging.

## Resources Created

| Resource | Description |
|---|---|
| `azurerm_service_plan` | Premium v3 App Service Plan with zone balancing |
| `azurerm_linux_web_app` | Linux App Service with system-assigned identity and VNet integration |
| `azurerm_role_assignment` | Grants App Service managed identity `Key Vault Secrets User` role |
| `azurerm_private_endpoint` | Private endpoint for App Service (`sites` sub-resource) |
| `azurerm_monitor_autoscale_setting` | CPU and memory-based auto-scale rules (scale out at 70% CPU) |
| `azurerm_monitor_diagnostic_setting` | HTTP, console, audit, and platform logs sent to Log Analytics |

## WAF Alignment

- **Reliability**: Zone-balanced App Service Plan; health check endpoint with automatic unhealthy worker eviction; auto-scaling ensures capacity during traffic spikes.
- **Security**: Public network access disabled; HTTPS-only; TLS 1.2 minimum; FTP disabled; Key Vault references prevent secrets from appearing in app settings plaintext.
- **Performance Efficiency**: HTTP/2 enabled; auto-scaling reacts to CPU and memory pressure; `always_on` prevents cold starts.
- **Cost Optimization**: Scale-in rules remove excess instances during low traffic.
- **Operational Excellence**: All request logs, console logs, and audit events forwarded to Log Analytics; Application Insights instrumented via connection string.

## Usage

```hcl
module "app_service" {
  source = "./modules/app-service"

  resource_group_name              = azurerm_resource_group.main.name
  location                         = "eastus2"
  name_prefix                      = "myapp-prod"
  sku_name                         = "P3v3"
  plan_capacity                    = 3
  vnet_integration_subnet_id       = module.networking.app_service_subnet_id
  private_endpoint_subnet_id       = module.networking.private_endpoint_subnet_id
  private_dns_zone_id              = module.networking.sites_private_dns_zone_id
  key_vault_id                     = module.key_vault.key_vault_id
  sql_connection_string_uri        = module.sql_database.connection_string_key_vault_uri
  redis_connection_string_uri      = module.redis_cache.connection_string_key_vault_uri
  log_analytics_workspace_id       = module.monitoring.log_analytics_workspace_id
  app_insights_connection_string   = module.monitoring.app_insights_connection_string
  app_insights_instrumentation_key = module.monitoring.app_insights_instrumentation_key
  tags                             = { environment = "prod" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `resource_group_name` | Resource group name | `string` | — | yes |
| `location` | Azure region | `string` | — | yes |
| `name_prefix` | Resource name prefix | `string` | — | yes |
| `sku_name` | App Service Plan SKU (Premium v3) | `string` | `"P3v3"` | no |
| `plan_capacity` | Number of workers | `number` | `3` | no |
| `autoscale_min_count` | Auto-scale minimum instances | `number` | `2` | no |
| `autoscale_max_count` | Auto-scale maximum instances | `number` | `10` | no |
| `key_vault_id` | Key Vault ID for RBAC | `string` | — | yes |
| `sql_connection_string_uri` | Key Vault URI for SQL connection string | `string` | — | yes |
| `redis_connection_string_uri` | Key Vault URI for Redis connection string | `string` | — | yes |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `app_service_id` | App Service resource ID |
| `app_service_default_hostname` | App Service default hostname |
| `app_service_principal_id` | Managed identity principal ID |
