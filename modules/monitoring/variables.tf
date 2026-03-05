variable "log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace."
  type        = string
}

variable "app_insights_name" {
  description = "The name of the Application Insights instance."
  type        = string
}

variable "location" {
  description = "The Azure region where the monitoring resources should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "log_retention_days" {
  description = "The number of days to retain logs in the Log Analytics workspace."
  type        = number
  default     = 90

  validation {
    condition     = contains([30, 60, 90, 120, 180, 270, 365, 550, 730], var.log_retention_days)
    error_message = "Log retention days must be one of: 30, 60, 90, 120, 180, 270, 365, 550, 730."
  }
}

variable "application_type" {
  description = "The type of application being monitored."
  type        = string
  default     = "web"

  validation {
    condition     = contains(["web", "ios", "java", "phone", "store", "other"], var.application_type)
    error_message = "Application type must be one of: web, ios, java, phone, store, other."
  }
}

variable "app_insights_retention_days" {
  description = "The number of days to retain Application Insights data."
  type        = number
  default     = 90
}

variable "daily_data_cap_gb" {
  description = "The daily data cap (in GB) for Application Insights."
  type        = number
  default     = 10
}

variable "action_group_name" {
  description = "The name of the monitoring action group."
  type        = string
}

variable "action_group_short_name" {
  description = "The short name of the action group (max 12 chars)."
  type        = string

  validation {
    condition     = length(var.action_group_short_name) <= 12
    error_message = "Action group short name must be 12 characters or fewer."
  }
}

variable "alert_email_receivers" {
  description = "A list of email receivers for alerts."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "alert_name_prefix" {
  description = "A prefix to use for all alert names."
  type        = string
}

variable "app_service_plan_id" {
  description = "The ID of the App Service Plan to monitor."
  type        = string
  default     = null
}

variable "web_app_id" {
  description = "The ID of the Web App to monitor."
  type        = string
  default     = null
}

variable "front_door_profile_id" {
  description = "The ID of the Front Door profile to monitor."
  type        = string
  default     = null
}

variable "cpu_alert_threshold" {
  description = "The CPU percentage threshold for triggering an alert."
  type        = number
  default     = 85
}

variable "memory_alert_threshold" {
  description = "The memory percentage threshold for triggering an alert."
  type        = number
  default     = 85
}

variable "http5xx_alert_threshold" {
  description = "The number of HTTP 5xx errors per window to trigger an alert."
  type        = number
  default     = 10
}

variable "response_time_alert_threshold" {
  description = "The average response time (in seconds) threshold for triggering an alert."
  type        = number
  default     = 5
}

variable "create_dashboard" {
  description = "Whether to create an Azure Portal dashboard."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
