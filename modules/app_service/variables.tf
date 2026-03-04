variable "app_name" {
  description = "The name of the Linux web app."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the App Service will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where App Service resources will be created."
  type        = string
}

variable "app_service_plan_name" {
  description = "The name of the App Service Plan."
  type        = string
}

variable "subnet_id" {
  description = "The resource ID of the subnet used for VNet integration."
  type        = string
}

variable "key_vault_uri" {
  description = "The URI of the Azure Key Vault used by the application."
  type        = string
}

variable "app_insights_connection_string" {
  description = "The Application Insights connection string."
  type        = string
  sensitive   = true
}

variable "app_insights_key" {
  description = "The Application Insights instrumentation key."
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "The resource ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

variable "health_check_path" {
  description = "The path for the App Service health check endpoint."
  type        = string
  default     = "/health"
}

variable "allowed_front_door_header" {
  description = "The Azure Front Door profile ID (GUID) used to restrict inbound traffic via X-Azure-FDID header. Leave empty to skip header validation."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to apply to App Service resources."
  type        = map(string)
  default     = {}
}
