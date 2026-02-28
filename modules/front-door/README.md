# Front Door Module

## Overview

This module provisions Azure Front Door Premium with a WAF policy (OWASP + Bot Manager managed rules), a private link origin pointing to the App Service, HTTPS-only routing with caching, and full diagnostic logging.

## Resources Created

| Resource | Description |
|---|---|
| `azurerm_cdn_frontdoor_profile` | Premium Front Door profile |
| `azurerm_cdn_frontdoor_endpoint` | Public-facing CDN endpoint |
| `azurerm_cdn_frontdoor_firewall_policy` | WAF policy with `Microsoft_DefaultRuleSet` 2.1 and `Microsoft_BotManagerRuleSet` 1.1 |
| `azurerm_cdn_frontdoor_security_policy` | Associates WAF policy with the endpoint |
| `azurerm_cdn_frontdoor_origin_group` | Origin group with health probes and latency-based routing |
| `azurerm_cdn_frontdoor_origin` | App Service origin with private link |
| `azurerm_cdn_frontdoor_route` | Route from endpoint to origin with HTTPS redirect and response caching |
| `azurerm_monitor_diagnostic_setting` | Access, health probe, and WAF logs sent to Log Analytics |

## WAF Alignment

- **Reliability**: Health probe every 30 seconds detects origin failures; latency-based load balancing distributes traffic optimally.
- **Security**: WAF in Prevention mode blocks OWASP Top 10 attacks and bots; HTTPS redirect enforced; private link prevents App Service from being accessible directly over the internet.
- **Performance Efficiency**: Response caching for static content types (CSS, JS, HTML, JSON) reduces origin load; HTTP/2 enabled at the origin.
- **Operational Excellence**: Access logs, WAF logs, and health probe logs forwarded to Log Analytics for centralized analysis.

## Usage

```hcl
module "front_door" {
  source = "./modules/front-door"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = "eastus2"
  name_prefix                = "myapp-prod"
  app_service_hostname       = module.app_service.app_service_default_hostname
  app_service_resource_id    = module.app_service.app_service_id
  waf_mode                   = "Prevention"
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = { environment = "prod" }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|---|---|---|---|---|
| `resource_group_name` | Resource group name | `string` | — | yes |
| `location` | Azure region for App Service (private link) | `string` | — | yes |
| `name_prefix` | Resource name prefix | `string` | — | yes |
| `app_service_hostname` | App Service default hostname | `string` | — | yes |
| `app_service_resource_id` | App Service resource ID | `string` | — | yes |
| `waf_mode` | WAF mode (`Detection` or `Prevention`) | `string` | `"Prevention"` | no |
| `log_analytics_workspace_id` | Log Analytics Workspace ID | `string` | — | yes |
| `tags` | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|---|---|
| `profile_id` | Front Door profile resource ID |
| `endpoint_hostname` | Public Front Door endpoint hostname |
| `waf_policy_id` | WAF policy resource ID |
