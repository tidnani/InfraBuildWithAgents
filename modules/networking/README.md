# Networking Module

## Overview

This module provisions the foundational networking infrastructure for the Mission Critical Azure App Service architecture. It follows the Azure Well-Architected Framework (WAF) principles for reliability, security, and operational excellence.

## Resources Created

| Resource | Description |
|---|---|
| `azurerm_virtual_network` | Hub VNet for all workload resources |
| `azurerm_subnet` (app_service) | Dedicated subnet with `Microsoft.Web/serverFarms` service delegation for VNet integration |
| `azurerm_subnet` (private_endpoints) | Isolated subnet for all private endpoint NICs |
| `azurerm_subnet` (AzureBastionSubnet) | Required subnet for Azure Bastion secure access |
| `azurerm_network_security_group` (x2) | NSGs enforcing least-privilege inbound/outbound traffic |
| `azurerm_bastion_host` | Standard SKU Bastion for secure VM access without public IPs |
| `azurerm_private_dns_zone` (x5) | Private DNS zones for blob, SQL, Redis, Key Vault, and App Service |
| `azurerm_private_dns_zone_virtual_network_link` (x5) | Links each DNS zone to the VNet for private name resolution |

## WAF Alignment

- **Reliability**: Zone-redundant Bastion public IP across three availability zones.
- **Security**: NSGs deny all inbound traffic by default; App Service subnet only accepts traffic from `AzureFrontDoor.Backend`; private DNS zones prevent public DNS resolution of PaaS endpoints.
- **Operational Excellence**: Consistent naming convention via `name_prefix`; all resources tagged for cost allocation and lifecycle management.

## Usage

```hcl
module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2"
  name_prefix         = "myapp-prod"
  vnet_address_space  = ["10.0.0.0/16"]
  tags                = { environment = "prod" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `resource_group_name` | Resource group name | `string` | — | yes |
| `location` | Azure region | `string` | — | yes |
| `name_prefix` | Resource name prefix | `string` | — | yes |
| `vnet_address_space` | VNet address space | `list(string)` | `["10.0.0.0/16"]` | no |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `vnet_id` | VNet resource ID |
| `app_service_subnet_id` | App Service integration subnet ID |
| `private_endpoint_subnet_id` | Private endpoint subnet ID |
| `sql_private_dns_zone_id` | SQL private DNS zone ID |
| `redis_private_dns_zone_id` | Redis private DNS zone ID |
| `keyvault_private_dns_zone_id` | Key Vault private DNS zone ID |
| `sites_private_dns_zone_id` | App Service private DNS zone ID |
