variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the App Service origin (used for Front Door private link)."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used for naming all resources in this module."
  type        = string
}

variable "app_service_hostname" {
  description = "Default hostname of the App Service origin."
  type        = string
}

variable "app_service_resource_id" {
  description = "Resource ID of the App Service for Front Door private link."
  type        = string
}

variable "waf_mode" {
  description = "WAF policy mode: 'Detection' or 'Prevention'."
  type        = string
  default     = "Prevention"
  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "WAF mode must be 'Detection' or 'Prevention'."
  }
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics Workspace for diagnostic settings."
  type        = string
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
