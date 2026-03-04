variable "key_vault_name" {
  description = "The name of the Azure Key Vault. Must be globally unique, 3-24 characters, alphanumeric and hyphens only."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.key_vault_name))
    error_message = "Key Vault name must be 3-24 characters, containing only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group where the Key Vault will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where the Key Vault will be created."
  type        = string
}

variable "subnet_id" {
  description = "The resource ID of the subnet in which to create the Key Vault private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "The resource ID of the Key Vault private DNS zone (privatelink.vaultcore.azure.net)."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID for the Key Vault."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to Key Vault resources."
  type        = map(string)
  default     = {}
}
