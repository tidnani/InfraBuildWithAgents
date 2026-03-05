variable "project_name" {
  description = "The project name used as a prefix for all resources."
  type        = string
  default     = "mcritic"
}

variable "primary_location" {
  description = "The primary Azure region for resources."
  type        = string
  default     = "eastus2"
}

variable "secondary_location" {
  description = "The secondary Azure region for geo-redundant resources."
  type        = string
  default     = "westus3"
}

variable "node_version" {
  description = "The Node.js version for the web app (e.g., '20-lts')."
  type        = string
  default     = "20-lts"
}

variable "alert_email_receivers" {
  description = "A list of email receivers for monitoring alerts."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "tags" {
  description = "Additional tags to assign to all resources."
  type        = map(string)
  default     = {}
}
