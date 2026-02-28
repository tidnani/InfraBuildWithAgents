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

variable "retention_days" {
  description = "Data retention period in days for Log Analytics and Application Insights."
  type        = number
  default     = 90
  validation {
    condition     = var.retention_days >= 30 && var.retention_days <= 730
    error_message = "Retention days must be between 30 and 730."
  }
}

variable "alert_email_addresses" {
  description = "List of email addresses to receive monitoring alerts."
  type        = list(string)
  default     = []
}

variable "error_rate_threshold" {
  description = "Failed request count threshold that triggers the error rate alert."
  type        = number
  default     = 10
  validation {
    condition     = var.error_rate_threshold > 0
    error_message = "Error rate threshold must be a positive number."
  }
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}
