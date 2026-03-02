variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network (list of CIDR blocks)."
  type        = list(string)
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "subnets" {
  description = "Map of subnet configurations. Each entry requires address_prefix and optional service_delegation."
  type = map(object({
    address_prefix = string
    service_delegation = optional(object({
      name    = string
      actions = list(string)
    }), null)
  }))
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
