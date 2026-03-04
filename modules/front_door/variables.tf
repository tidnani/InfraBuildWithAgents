variable "profile_name" {
  description = "The name of the Azure Front Door profile."
  type        = string
}

variable "endpoint_name" {
  description = "The name of the Front Door endpoint."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where Front Door resources will be created."
  type        = string
}

variable "origins" {
  description = "A list of origin configurations for the Front Door origin group."
  type = list(object({
    name                   = string
    host_name              = string
    private_link_location  = string
    private_link_target_id = string
  }))

  validation {
    condition     = length(var.origins) > 0
    error_message = "At least one origin must be provided."
  }
}

variable "tags" {
  description = "A map of tags to apply to Front Door resources."
  type        = map(string)
  default     = {}
}
