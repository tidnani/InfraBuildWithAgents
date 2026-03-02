variable "redis_cache_name" {
  description = "The name of the Azure Cache for Redis instance."
  type        = string
}

variable "location" {
  description = "The Azure region where the Redis Cache will be created."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for Redis Cache. Must be 'Premium' for zone redundancy."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_name)
    error_message = "SKU name must be one of: Basic, Standard, Premium."
  }
}

variable "family" {
  description = "The cache family. C for Basic/Standard, P for Premium."
  type        = string
  default     = "P"

  validation {
    condition     = contains(["C", "P"], var.family)
    error_message = "Family must be either 'C' (Basic/Standard) or 'P' (Premium)."
  }
}

variable "capacity" {
  description = "The cache capacity (size). For Premium: 1, 2, 3, 4, 5."
  type        = number
  default     = 1
}

variable "enable_non_ssl_port" {
  description = "Whether to enable the non-SSL port (6379). Should be disabled for security."
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "The minimum TLS version. Recommended: 1.2"
  type        = string
  default     = "1.2"
}

variable "maxmemory_policy" {
  description = "The eviction policy when memory is full."
  type        = string
  default     = "allkeys-lru"
}

variable "rdb_backup_enabled" {
  description = "Whether RDB backup is enabled (requires Premium SKU)."
  type        = bool
  default     = true
}

variable "rdb_backup_frequency" {
  description = "The backup frequency in minutes (60, 360, or 720)."
  type        = number
  default     = 60
}

variable "rdb_backup_max_snapshot_count" {
  description = "The maximum number of snapshots to retain."
  type        = number
  default     = 1
}

variable "rdb_storage_connection_string" {
  description = "The storage account connection string for RDB backups."
  type        = string
  sensitive   = true
  default     = null
}

variable "zones" {
  description = "List of availability zones for zone-redundant deployment."
  type        = list(string)
  default     = ["1", "2", "3"]
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
