variable "vnet_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "location" {
  description = "The Azure region where the networking resources should be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where networking resources will be created."
  type        = string
}

variable "vnet_address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "app_service_subnet_name" {
  description = "The name of the subnet for App Service VNet integration."
  type        = string
  default     = "app-service-integration"
}

variable "app_service_subnet_prefixes" {
  description = "The address prefixes for the App Service integration subnet."
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "private_endpoint_subnet_name" {
  description = "The name of the subnet for private endpoints."
  type        = string
  default     = "private-endpoints"
}

variable "private_endpoint_subnet_prefixes" {
  description = "The address prefixes for the private endpoints subnet."
  type        = list(string)
  default     = ["10.0.2.0/24"]
}

variable "tags" {
  description = "A map of tags to assign to resources."
  type        = map(string)
  default     = {}
}
