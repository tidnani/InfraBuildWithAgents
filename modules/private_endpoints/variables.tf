variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be created."
  type        = string
}

variable "virtual_network_id" {
  description = "The ID of the virtual network for DNS zone VNet links."
  type        = string
}

variable "private_endpoints" {
  description = "Map of private endpoint configurations."
  type = map(object({
    name                           = string
    subnet_id                      = string
    private_connection_resource_id = string
    subresource_names              = list(string)
    private_dns_zone_ids           = optional(list(string), [])
  }))
  default = {}
}

variable "create_dns_zones" {
  description = "Whether to create private DNS zones for SQL, Redis, and Key Vault."
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to all resources."
  type        = map(string)
  default     = {}
}
