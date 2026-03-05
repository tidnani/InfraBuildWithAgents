output "front_door_id" {
  description = "The ID of the Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "front_door_name" {
  description = "The name of the Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.this.name
}

output "endpoint_hostname" {
  description = "The hostname of the Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "endpoint_id" {
  description = "The ID of the Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.this.id
}

output "waf_policy_id" {
  description = "The ID of the WAF policy."
  value       = azurerm_cdn_frontdoor_firewall_policy.this.id
}

output "origin_group_id" {
  description = "The ID of the origin group."
  value       = azurerm_cdn_frontdoor_origin_group.this.id
}

output "front_door_profile_resource_guid" {
  description = "The resource GUID of the Front Door profile, used for App Service access restriction."
  value       = azurerm_cdn_frontdoor_profile.this.resource_guid
}
