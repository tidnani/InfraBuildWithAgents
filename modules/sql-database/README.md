# SQL Database Module

## Overview

This module provisions an Azure SQL Database in the Business Critical tier with automatic failover to a secondary region, private endpoints, comprehensive diagnostic logging, and long-term backup retention.

## Resources Created

| Resource | Description |
|---|---|
| `azurerm_mssql_server` (primary) | Primary SQL Server with Azure AD admin, system-assigned identity |
| `azurerm_mssql_server` (secondary) | Secondary SQL Server in a different region for geo-redundancy |
| `azurerm_mssql_database` | Business Critical database with zone redundancy and threat detection |
| `azurerm_mssql_failover_group` | Automatic failover group with 60-minute grace period |
| `azurerm_private_endpoint` | Private endpoint for primary SQL Server |
| `azurerm_monitor_diagnostic_setting` | Sends SQL insights, wait stats, deadlocks to Log Analytics |
| `azurerm_key_vault_secret` | Stores the connection string in Key Vault |

## WAF Alignment

- **Reliability**: Automatic failover group with secondary in a different region; zone-redundant database; 35-day short-term and 5-year long-term backup retention.
- **Security**: Public network access disabled; private endpoint only; minimum TLS 1.2; threat detection enabled; Azure AD administrator configured.
- **Operational Excellence**: Full diagnostic logging including query store, deadlocks, and wait statistics sent to centralised Log Analytics.

## Usage

```hcl
module "sql_database" {
  source = "./modules/sql-database"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = "eastus2"
  secondary_location         = "westus2"
  name_prefix                = "myapp-prod"
  sku_name                   = "BC_Gen5_4"
  admin_login                = "sqladmin"
  admin_password             = var.sql_admin_password
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_id        = module.networking.sql_private_dns_zone_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  key_vault_id               = module.key_vault.key_vault_id
  tags                       = { environment = "prod" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `resource_group_name` | Resource group name | `string` | — | yes |
| `location` | Primary Azure region | `string` | — | yes |
| `secondary_location` | Secondary region for geo-replication | `string` | — | yes |
| `name_prefix` | Resource name prefix | `string` | — | yes |
| `sku_name` | SQL Database SKU | `string` | `"BC_Gen5_4"` | no |
| `admin_login` | SQL admin login | `string` | `"sqladmin"` | no |
| `admin_password` | SQL admin password (sensitive) | `string` | — | yes |
| `key_vault_id` | Key Vault ID for storing secrets | `string` | — | yes |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `sql_server_fqdn` | Primary SQL Server FQDN |
| `failover_group_id` | SQL Failover Group resource ID |
| `connection_string_key_vault_uri` | Key Vault reference URI for the connection string |
