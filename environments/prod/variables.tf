variable "subscription_id" {
  description = "The Azure subscription ID."
  type        = string
}

variable "tenant_id" {
  description = "The Azure AD tenant ID."
  type        = string
}

variable "location" {
  description = "The primary Azure region for resource deployment."
  type        = string
  default     = "eastus"
}

variable "location_short" {
  description = "Short abbreviation for the Azure region (used in resource naming)."
  type        = string
  default     = "eus"
}

variable "project_name" {
  description = "The name of the project (used in resource naming)."
  type        = string
  default     = "myapp"
}

variable "owner_tag" {
  description = "The owner tag value for resource tagging."
  type        = string
  default     = "platform-team"
}

variable "cost_center_tag" {
  description = "The cost center tag value for resource tagging."
  type        = string
  default     = "engineering"
}

variable "log_retention_in_days" {
  description = "The number of days to retain logs in Log Analytics."
  type        = number
  default     = 90
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = string
  default     = "10.0.0.0/16"
}

variable "app_service_subnet_prefix" {
  description = "The address prefix for the App Service subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_endpoint_subnet_prefix" {
  description = "The address prefix for the private endpoint subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "management_subnet_prefix" {
  description = "The address prefix for the management subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "sql_admin_login" {
  description = "The SQL Server administrator login name."
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "The SQL Server administrator password."
  type        = string
  sensitive   = true
}

variable "azuread_admin_login" {
  description = "The Azure AD administrator login for SQL Server."
  type        = string
}

variable "azuread_admin_object_id" {
  description = "The object ID of the Azure AD administrator for SQL Server."
  type        = string
}

variable "redis_backup_storage_connection_string" {
  description = "The storage account connection string for Redis RDB backups."
  type        = string
  sensitive   = true
  default     = null
}
