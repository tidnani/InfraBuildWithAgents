variable "server_name" {
  description = "The name of the Azure SQL Server."
  type        = string
}

variable "database_name" {
  description = "The name of the Azure SQL Database."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "administrator_login" {
  description = "The administrator login name for the SQL Server."
  type        = string
}

variable "administrator_login_password" {
  description = "The administrator login password for the SQL Server."
  type        = string
  sensitive   = true
}

variable "azuread_admin_login" {
  description = "The Azure AD administrator login name."
  type        = string
}

variable "azuread_admin_object_id" {
  description = "The object ID of the Azure AD administrator."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the SQL Database (e.g., GP_Gen5_4 for General Purpose)."
  type        = string
  default     = "GP_Gen5_4"
}

variable "zone_redundant" {
  description = "Whether zone redundancy is enabled for the database."
  type        = bool
  default     = true
}

variable "short_term_retention_days" {
  description = "The number of days to retain short-term backups (1-35)."
  type        = number
  default     = 7

  validation {
    condition     = var.short_term_retention_days >= 1 && var.short_term_retention_days <= 35
    error_message = "Short-term retention days must be between 1 and 35."
  }
}

variable "ltr_weekly_retention" {
  description = "Long-term retention policy for weekly backups (ISO 8601 duration)."
  type        = string
  default     = "P1W"
}

variable "ltr_monthly_retention" {
  description = "Long-term retention policy for monthly backups (ISO 8601 duration)."
  type        = string
  default     = "P1M"
}

variable "ltr_yearly_retention" {
  description = "Long-term retention policy for yearly backups (ISO 8601 duration)."
  type        = string
  default     = "P1Y"
}

variable "audit_retention_in_days" {
  description = "The number of days to retain audit logs."
  type        = number
  default     = 90
}

variable "vulnerability_assessment_storage_container_path" {
  description = "The storage container path for vulnerability assessment results."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace for diagnostic settings."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
