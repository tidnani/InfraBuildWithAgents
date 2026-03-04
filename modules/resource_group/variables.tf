variable "name" {
  description = "The name of the resource group."
  type        = string

  validation {
    condition     = length(var.name) > 0 && length(var.name) <= 90
    error_message = "Resource group name must be between 1 and 90 characters."
  }
}

variable "location" {
  description = "The Azure region where the resource group will be created."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to the resource group."
  type        = map(string)
  default     = {}
}
