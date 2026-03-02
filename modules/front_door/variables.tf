variable "front_door_name" {
  description = "The name of the Azure Front Door profile."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "waf_policy_name" {
  description = "The name of the WAF policy."
  type        = string
}

variable "origins" {
  description = "List of origin configurations for the Front Door origin group."
  type = list(object({
    name               = string
    host_name          = string
    origin_host_header = string
    priority           = number
    weight             = number
  }))
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace for diagnostic settings."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
