variable "subscription_id" {
  description = "The Azure subscription ID where resources will be deployed."
  type        = string
}

variable "tenant_id" {
  description = "The Azure Active Directory tenant ID."
  type        = string
}

variable "prefix" {
  description = "A short prefix used to name all resources. Must be lowercase alphanumeric, 2-8 characters."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{2,8}$", var.prefix))
    error_message = "prefix must be 2-8 lowercase alphanumeric characters."
  }
}

variable "alert_email" {
  description = "The email address to send monitoring alerts to."
  type        = string
}

variable "health_check_path" {
  description = "The URL path for App Service health checks."
  type        = string
  default     = "/health"
}

variable "http_5xx_threshold" {
  description = "Number of HTTP 5xx errors per minute before an alert is triggered."
  type        = number
  default     = 10
}

variable "front_door_profile_id" {
  description = "The Front Door profile GUID for X-Azure-FDID IP restriction. Obtain from Front Door outputs after initial deployment and re-apply."
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags applied to all resources in this environment."
  type        = map(string)
  default = {
    environment = "prod"
    managed-by  = "terraform"
  }
}
