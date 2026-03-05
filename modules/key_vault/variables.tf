variable "name" {
  description = "The name of the Key Vault. Must be globally unique."
  type        = string

  validation {
    condition     = length(var.name) >= 3 && length(var.name) <= 24 && can(regex("^[a-zA-Z][a-zA-Z0-9-]*$", var.name))
    error_message = "Key Vault name must be 3-24 characters, start with a letter, and contain only letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the Key Vault should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Key Vault."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "SKU must be either 'standard' or 'premium'."
  }
}

variable "soft_delete_retention_days" {
  description = "The number of days soft-deleted secrets are retained."
  type        = number
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90."
  }
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet for the private endpoint."
  type        = string
}

variable "key_vault_private_dns_zone_id" {
  description = "The ID of the Key Vault private DNS zone."
  type        = string
}

variable "allowed_ip_rules" {
  description = "A list of IP addresses or CIDR blocks to allow access to the Key Vault."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "A list of subnet IDs to allow access to the Key Vault."
  type        = list(string)
  default     = []
}

variable "web_app_principal_ids" {
  description = "A list of principal IDs (managed identity) of web apps that need Key Vault Secrets User access."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
