output "profile_id" {
  description = "The ID of the Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "profile_name" {
  description = "The name of the Front Door profile."
  value       = azurerm_cdn_frontdoor_profile.this.name
}

output "endpoint_hostname" {
  description = "The hostname of the Front Door endpoint."
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "waf_policy_id" {
  description = "The ID of the WAF policy."
  value       = azurerm_cdn_frontdoor_firewall_policy.this.id
}
