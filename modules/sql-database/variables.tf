variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "location" {
  description = "Primary Azure region for the SQL Server."
  type        = string
}

variable "secondary_location" {
  description = "Secondary Azure region for geo-replication and failover."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for naming all resources in this module."
  type        = string
}

variable "sku_name" {
  description = "SKU name for the Azure SQL Database. Business Critical (BC_*) is recommended for production."
  type        = string
  default     = "BC_Gen5_4"
}

variable "admin_login" {
  description = "SQL Server administrator login name."
  type        = string
  default     = "sqladmin"
}

variable "admin_password" {
  description = "SQL Server administrator password."
  type        = string
  sensitive   = true
}

variable "aad_admin_object_id" {
  description = "Azure AD object ID for the SQL Server Azure AD administrator. Defaults to the current Terraform principal."
  type        = string
  default     = ""
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the subnet for the SQL Server private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the SQL Server private DNS zone."
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
