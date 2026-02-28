# Redis Cache Module

## Overview

This module provisions Azure Cache for Redis (Premium SKU) with private endpoint access, TLS-only connections, zone redundancy, and connection string storage in Key Vault.

## Resources Created

| Resource | Description |
|---|---|
| `azurerm_redis_cache` | Premium Redis cache with zone redundancy, LRU eviction, maintenance window |
| `azurerm_private_endpoint` | Private endpoint for Redis (`redisCache` sub-resource) |
| `azurerm_key_vault_secret` | Stores the Redis connection string in Key Vault |
| `azurerm_monitor_diagnostic_setting` | Sends connected client list and all metrics to Log Analytics |

## WAF Alignment

- **Reliability**: Zone-redundant deployment (Premium SKU) across three availability zones; scheduled maintenance window minimises unplanned disruptions.
- **Security**: Public network access disabled; TLS 1.2 minimum; private endpoint enforces network isolation; access keys stored in Key Vault.
- **Performance Efficiency**: `allkeys-lru` eviction policy optimises cache hit rates under memory pressure.
- **Operational Excellence**: Diagnostic settings send cache metrics and connection events to centralised Log Analytics.

## Usage

```hcl
module "redis_cache" {
  source = "./modules/redis-cache"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = "eastus2"
  name_prefix                = "myapp-prod"
  capacity                   = 1
  family                     = "P"
  sku_name                   = "Premium"
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_id        = module.networking.redis_private_dns_zone_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  key_vault_id               = module.key_vault.key_vault_id
  tags                       = { environment = "prod" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `resource_group_name` | Resource group name | `string` | — | yes |
| `location` | Azure region | `string` | — | yes |
| `name_prefix` | Resource name prefix | `string` | — | yes |
| `capacity` | Cache size in GB | `number` | `1` | no |
| `family` | Cache family (`C` or `P`) | `string` | `"P"` | no |
| `sku_name` | Cache SKU | `string` | `"Premium"` | no |
| `key_vault_id` | Key Vault ID for storing secrets | `string` | — | yes |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `redis_hostname` | Redis Cache hostname |
| `connection_string_key_vault_uri` | Key Vault reference URI for the connection string |
