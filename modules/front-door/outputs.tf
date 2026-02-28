output "profile_id" {
  description = "Resource ID of the Azure Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.main.id
}

output "profile_name" {
  description = "Name of the Azure Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.main.name
}

output "endpoint_id" {
  description = "Resource ID of the Azure Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.main.id
}

output "endpoint_hostname" {
  description = "Public hostname of the Azure Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.main.host_name
}

output "waf_policy_id" {
  description = "Resource ID of the Azure Front Door WAF policy."
  value       = azurerm_cdn_frontdoor_firewall_policy.main.id
}

output "origin_group_id" {
  description = "Resource ID of the Front Door origin group."
  value       = azurerm_cdn_frontdoor_origin_group.app_service.id
}
