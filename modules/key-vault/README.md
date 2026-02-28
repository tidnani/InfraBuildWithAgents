# Key Vault Module

## Overview

This module provisions Azure Key Vault with RBAC authorization, private endpoint, and stores the SQL administrator password as a secret. Public network access is disabled; all access routes through the private endpoint.

## Resources Created

| Resource | Description |
|---|---|
| `azurerm_key_vault` | Premium SKU Key Vault with RBAC, soft-delete (90 days), and purge protection |
| `azurerm_private_endpoint` | Private endpoint for Key Vault (`vault` sub-resource) |
| `azurerm_role_assignment` | Grants the deploying principal `Key Vault Administrator` role |
| `azurerm_key_vault_secret` | Stores the SQL admin password |
| `azurerm_monitor_diagnostic_setting` | Sends audit logs and metrics to Log Analytics |

## WAF Alignment

- **Security**: RBAC authorization replaces vault access policies; public access disabled; private endpoint enforces network isolation; soft-delete and purge protection prevent accidental data loss.
- **Reliability**: Soft-delete with 90-day retention and purge protection ensure secrets can be recovered.
- **Operational Excellence**: All key access events streamed to Log Analytics for auditing and compliance.

## Usage

```hcl
module "key_vault" {
  source = "./modules/key-vault"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = "eastus2"
  name_prefix                = "myapp-prod"
  sku_name                   = "premium"
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_id        = module.networking.keyvault_private_dns_zone_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  sql_admin_password         = var.sql_admin_password
  tags                       = { environment = "prod" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `resource_group_name` | Resource group name | `string` | — | yes |
| `location` | Azure region | `string` | — | yes |
| `name_prefix` | Resource name prefix | `string` | — | yes |
| `sku_name` | Key Vault SKU | `string` | `"premium"` | no |
| `private_endpoint_subnet_id` | Private endpoint subnet ID | `string` | — | yes |
| `private_dns_zone_id` | Key Vault private DNS zone ID | `string` | — | yes |
| `log_analytics_workspace_id` | Log Analytics Workspace ID | `string` | — | yes |
| `sql_admin_password` | SQL admin password (sensitive) | `string` | — | yes |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `key_vault_id` | Key Vault resource ID |
| `key_vault_uri` | Key Vault URI |
| `sql_admin_password_secret_uri` | Versionless URI for Key Vault reference in App Service |
