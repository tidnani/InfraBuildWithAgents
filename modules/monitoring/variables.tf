variable "workspace_name" {
  description = "The name of the Log Analytics Workspace."
  type        = string
}

variable "app_insights_name" {
  description = "The name of the Application Insights instance."
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

variable "retention_in_days" {
  description = "The number of days to retain logs in Log Analytics Workspace (minimum 30)."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_in_days >= 30
    error_message = "Retention in days must be at least 30."
  }
}

variable "alert_scope_ids" {
  description = "List of resource IDs to scope the metric alerts to."
  type        = list(string)
  default     = []
}

variable "alert_email_receivers" {
  description = "List of email receivers for alert action group."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
