variable "workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
}

variable "app_insights_name" {
  description = "The name of the Application Insights component."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where monitoring resources will be created."
  type        = string
}

variable "location" {
  description = "The Azure region where monitoring resources will be created."
  type        = string
}

variable "action_group_name" {
  description = "The name of the Azure Monitor action group for alerts."
  type        = string
}

variable "alert_email" {
  description = "The email address to receive alert notifications."
  type        = string

  validation {
    condition     = can(regex("^[^@]+@[^@]+\\.[^@]+$", var.alert_email))
    error_message = "alert_email must be a valid email address."
  }
}

variable "app_service_id" {
  description = "The resource ID of the App Service (used for HTTP 5xx alerts). Leave empty to skip alert creation."
  type        = string
  default     = ""
}

variable "app_service_plan_id" {
  description = "The resource ID of the App Service Plan (used for CPU and memory alerts). Leave empty to skip alert creation."
  type        = string
  default     = ""
}

variable "http_5xx_threshold" {
  description = "The threshold for HTTP 5xx error count before triggering an alert."
  type        = number
  default     = 10
}

variable "tags" {
  description = "A map of tags to apply to monitoring resources."
  type        = map(string)
  default     = {}
}
