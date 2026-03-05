variable "app_service_plan_name" {
  description = "The name of the App Service Plan."
  type        = string
}

variable "web_app_name" {
  description = "The name of the Linux Web App."
  type        = string
}

variable "location" {
  description = "The Azure region where the App Service resources should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the App Service Plan. Use P1v3 or higher for zone redundancy."
  type        = string
  default     = "P1v3"

  validation {
    condition     = contains(["P0v3", "P1v3", "P2v3", "P3v3", "P1mv3", "P2mv3", "P3mv3", "P4mv3", "P5mv3"], var.sku_name)
    error_message = "SKU must be a Premium v3 tier for zone redundancy and private endpoint support."
  }
}

variable "zone_balancing_enabled" {
  description = "Should zone balancing be enabled for the App Service Plan."
  type        = bool
  default     = true
}

variable "worker_count" {
  description = "The number of Workers for this App Service Plan. Minimum 3 for zone redundancy."
  type        = number
  default     = 3
}

variable "vnet_integration_subnet_id" {
  description = "The ID of the subnet for VNet integration."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet for the private endpoint."
  type        = string
}

variable "app_service_private_dns_zone_id" {
  description = "The ID of the private DNS zone for App Service."
  type        = string
}

variable "health_check_path" {
  description = "The path for the health check endpoint."
  type        = string
  default     = "/health"
}

variable "app_insights_connection_string" {
  description = "The Application Insights connection string."
  type        = string
  sensitive   = true
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

variable "user_assigned_identity_id" {
  description = "The ID of the User Assigned Managed Identity for Key Vault access."
  type        = string
  default     = null
}

variable "app_settings" {
  description = "A map of app settings for the web app."
  type        = map(string)
  default     = {}
}

variable "node_version" {
  description = "The Node.js version to use (e.g., '20-lts'). Set only one runtime version."
  type        = string
  default     = null
}

variable "python_version" {
  description = "The Python version to use (e.g., '3.12'). Set only one runtime version."
  type        = string
  default     = null
}

variable "dotnet_version" {
  description = "The .NET version to use (e.g., '8.0'). Set only one runtime version."
  type        = string
  default     = null
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
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
