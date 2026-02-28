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
  description = "SKU name for the App Service Plan (Premium v3 tier required for VNet integration)."
  type        = string
  default     = "P3v3"
  validation {
    condition     = can(regex("^P[0-9]v3$", var.sku_name))
    error_message = "App Service Plan SKU must be a Premium v3 tier (e.g. P1v3, P2v3, P3v3)."
  }
}

variable "plan_capacity" {
  description = "Number of workers for the App Service Plan."
  type        = number
  default     = 3
  validation {
    condition     = var.plan_capacity >= 1 && var.plan_capacity <= 30
    error_message = "Worker count must be between 1 and 30."
  }
}

variable "autoscale_min_count" {
  description = "Minimum number of instances for auto-scaling."
  type        = number
  default     = 2
}

variable "autoscale_max_count" {
  description = "Maximum number of instances for auto-scaling."
  type        = number
  default     = 10
}

variable "vnet_integration_subnet_id" {
  description = "Resource ID of the subnet for App Service VNet integration (requires Microsoft.Web/serverFarms delegation)."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Resource ID of the subnet for the App Service private endpoint."
  type        = string
}

variable "private_dns_zone_id" {
  description = "Resource ID of the App Service (sites) private DNS zone."
  type        = string
}

variable "key_vault_id" {
  description = "Resource ID of the Key Vault (used for RBAC assignment)."
  type        = string
}

variable "sql_connection_string_uri" {
  description = "Versionless Key Vault secret URI for the SQL connection string."
  type        = string
}

variable "redis_connection_string_uri" {
  description = "Versionless Key Vault secret URI for the Redis connection string."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace for diagnostic settings."
  type        = string
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string."
  type        = string
  sensitive   = true
}

variable "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
