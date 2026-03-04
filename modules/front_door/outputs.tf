output "front_door_id" {
  description = "The resource ID of the Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "front_door_profile_id" {
  description = "The unique GUID identifier of the Front Door profile, used for X-Azure-FDID header validation."
  value       = azurerm_cdn_frontdoor_profile.this.resource_guid
}

output "front_door_endpoint_hostname" {
  description = "The default hostname of the Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "front_door_endpoint_id" {
  description = "The resource ID of the Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.this.id
}

output "waf_policy_id" {
  description = "The resource ID of the Front Door WAF policy."
  value       = azurerm_cdn_frontdoor_firewall_policy.this.id
}

output "origin_group_id" {
  description = "The resource ID of the Front Door origin group."
  value       = azurerm_cdn_frontdoor_origin_group.this.id
}
