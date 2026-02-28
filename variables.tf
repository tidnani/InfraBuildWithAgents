variable "environment" {
  description = "Deployment environment name (dev, staging, prod)."
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Primary Azure region for resource deployment."
  type        = string
  default     = "eastus2"
}

variable "secondary_location" {
  description = "Secondary Azure region for geo-redundancy and failover."
  type        = string
  default     = "westus2"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group."
  type        = string
}

variable "application_name" {
  description = "Short name for the application, used as a prefix for resource naming."
  type        = string
  default     = "missioncritical"
  validation {
    condition     = can(regex("^[a-z0-9]{3,16}$", var.application_name))
    error_message = "Application name must be 3–16 lowercase alphanumeric characters."
  }
}

variable "tags" {
  description = "Map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

# Networking
variable "vnet_address_space" {
  description = "Address space for the Virtual Network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# App Service
variable "app_service_sku_name" {
  description = "SKU name for the App Service Plan (must be Premium v3 or higher for VNet integration)."
  type        = string
  default     = "P3v3"
  validation {
    condition     = can(regex("^P[0-9]v3$", var.app_service_sku_name))
    error_message = "App Service Plan SKU must be a Premium v3 tier (e.g. P1v3, P2v3, P3v3)."
  }
}

variable "app_service_plan_capacity" {
  description = "Number of workers for the App Service Plan."
  type        = number
  default     = 3
  validation {
    condition     = var.app_service_plan_capacity >= 1 && var.app_service_plan_capacity <= 30
    error_message = "App Service Plan capacity must be between 1 and 30."
  }
}

# SQL Database
variable "sql_admin_login" {
  description = "Administrator login for the Azure SQL Server."
  type        = string
  default     = "sqladmin"
}

variable "sql_admin_password" {
  description = "Administrator password for the Azure SQL Server. Stored in Key Vault."
  type        = string
  sensitive   = true
}

variable "sql_sku_name" {
  description = "SKU name for the Azure SQL Database (Business Critical tier recommended for production)."
  type        = string
  default     = "BC_Gen5_4"
}

# Redis Cache
variable "redis_capacity" {
  description = "Redis cache capacity (size of the cache in GB). Valid values: 1, 2, 4, 6, 13, 26, 53, 120."
  type        = number
  default     = 1
  validation {
    condition     = contains([1, 2, 4, 6, 13, 26, 53, 120], var.redis_capacity)
    error_message = "Redis capacity must be one of: 1, 2, 4, 6, 13, 26, 53, 120."
  }
}

variable "redis_family" {
  description = "Redis cache family. 'C' for Basic/Standard, 'P' for Premium."
  type        = string
  default     = "P"
  validation {
    condition     = contains(["C", "P"], var.redis_family)
    error_message = "Redis family must be 'C' (Basic/Standard) or 'P' (Premium)."
  }
}

variable "redis_sku_name" {
  description = "Redis cache SKU name."
  type        = string
  default     = "Premium"
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.redis_sku_name)
    error_message = "Redis SKU must be one of: Basic, Standard, Premium."
  }
}

# Key Vault
variable "key_vault_sku_name" {
  description = "SKU name for the Azure Key Vault."
  type        = string
  default     = "premium"
  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "Key Vault SKU must be 'standard' or 'premium'."
  }
}

# Monitoring
variable "log_analytics_retention_days" {
  description = "Retention period in days for the Log Analytics Workspace."
  type        = number
  default     = 90
  validation {
    condition     = var.log_analytics_retention_days >= 30 && var.log_analytics_retention_days <= 730
    error_message = "Log Analytics retention must be between 30 and 730 days."
  }
}

# Front Door WAF
variable "waf_mode" {
  description = "WAF policy mode. 'Detection' logs only; 'Prevention' blocks malicious requests."
  type        = string
  default     = "Prevention"
  validation {
    condition     = contains(["Detection", "Prevention"], var.waf_mode)
    error_message = "WAF mode must be 'Detection' or 'Prevention'."
  }
}
