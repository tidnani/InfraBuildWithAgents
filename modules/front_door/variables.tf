variable "front_door_name" {
  description = "The name of the Azure Front Door profile."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Front Door profile. Premium_AzureFrontDoor is required for private link origins."
  type        = string
  default     = "Premium_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku_name)
    error_message = "SKU must be either Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

variable "response_timeout_seconds" {
  description = "Specifies the maximum response timeout in seconds."
  type        = number
  default     = 120
}

variable "endpoint_name" {
  description = "The name of the Front Door endpoint."
  type        = string
}

variable "waf_policy_name" {
  description = "The name of the WAF policy."
  type        = string
}

variable "waf_mode" {
  description = "The WAF mode. Use Prevention in production."
  type        = string
  default     = "Prevention"

  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "WAF mode must be either Detection or Prevention."
  }
}

variable "waf_redirect_url" {
  description = "The redirect URL for WAF blocked requests."
  type        = string
  default     = null
}

variable "origin_group_name" {
  description = "The name of the origin group."
  type        = string
}

variable "health_probe_path" {
  description = "The path for health probe requests."
  type        = string
  default     = "/health"
}

variable "origins" {
  description = "A map of origin configurations."
  type = map(object({
    host_name                = string
    priority                 = number
    weight                   = number
    private_link_resource_id = optional(string)
    private_link_location    = optional(string)
  }))
}

variable "route_name" {
  description = "The name of the Front Door route."
  type        = string
  default     = "default-route"
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for diagnostic settings."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
