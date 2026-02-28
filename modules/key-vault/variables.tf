variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "location" {
  description = "Azure region for resource deployment."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for naming all resources in this module."
  type        = string
}

variable "sku_name" {
  description = "SKU for the Azure Key Vault ('standard' or 'premium')."
  type        = string
  default     = "premium"
  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "Key Vault SKU must be 'standard' or 'premium'."
  }
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the subnet used for the Key Vault private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the Key Vault private DNS zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace for diagnostic settings."
  type        = string
}

variable "sql_admin_password" {
  description = "SQL administrator password stored as a Key Vault secret."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
