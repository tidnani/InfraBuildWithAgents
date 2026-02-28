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

variable "capacity" {
  description = "Redis cache size in GB. Valid values depend on the SKU family."
  type        = number
  default     = 1
}

variable "family" {
  description = "Redis cache family: 'C' for Basic/Standard, 'P' for Premium."
  type        = string
  default     = "P"
  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "Redis family must be 'C' or 'P'."
  }
}

variable "sku_name" {
  description = "Redis cache SKU: Basic, Standard, or Premium."
  type        = string
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "Redis SKU must be one of: Basic, Standard, Premium."
  }
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the subnet for the Redis private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the Redis private DNS zone."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace for diagnostic settings."
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault where the connection string secret will be stored."
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
