variable "app_service_plan_name" {
  description = "The name of the App Service Plan."
  type        = string
}

variable "app_service_name" {
  description = "The name of the App Service (Web App)."
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

variable "sku_name" {
  description = "The SKU name for the App Service Plan (e.g., P3v3 for Premium v3)."
  type        = string
  default     = "P3v3"
}

variable "zone_balancing_enabled" {
  description = "Whether zone balancing is enabled for the App Service Plan."
  type        = bool
  default     = true
}

variable "app_settings" {
  description = "Map of application settings for the Web App."
  type        = map(string)
  default     = {}
}

variable "connection_strings" {
  description = "List of connection string configurations."
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default   = []
  sensitive = true
}

variable "subnet_id" {
  description = "The ID of the subnet for VNet integration."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace for diagnostic settings."
  type        = string
  default     = null
}

variable "app_insights_connection_string" {
  description = "The Application Insights connection string."
  type        = string
  sensitive   = true
}

variable "health_check_path" {
  description = "The health check path for the App Service."
  type        = string
  default     = "/health"
}

variable "dotnet_version" {
  description = "The .NET version to use for the application stack."
  type        = string
  default     = "8.0"
}

variable "autoscale_min_capacity" {
  description = "The minimum number of instances for autoscaling."
  type        = number
  default     = 3
}

variable "autoscale_max_capacity" {
  description = "The maximum number of instances for autoscaling."
  type        = number
  default     = 10
}

variable "autoscale_default_capacity" {
  description = "The default number of instances for autoscaling."
  type        = number
  default     = 3
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
