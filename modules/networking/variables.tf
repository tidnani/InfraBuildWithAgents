variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network (list of CIDR blocks)."
  type        = list(string)
}

variable "app_service_subnet_prefix" {
  description = "The CIDR prefix for the App Service integration subnet."
  type        = string
}

variable "private_endpoint_subnet_prefix" {
  description = "The CIDR prefix for the private endpoint subnet."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create networking resources."
  type        = string
}

variable "location" {
  description = "The Azure region where networking resources will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all networking resources."
  type        = map(string)
  default     = {}
}
