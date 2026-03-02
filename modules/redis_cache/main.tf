terraform {
  required_version = "~> 1.10"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

locals {
  tags = merge(var.tags, {
    managed_by = "terraform"
  })
}

resource "azurerm_redis_cache" "this" {
  name                          = var.redis_cache_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  capacity                      = var.capacity
  family                        = var.family
  sku_name                      = var.sku_name
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = false
  tags                          = local.tags

  redis_configuration {
    maxmemory_policy              = var.maxmemory_policy
    rdb_backup_enabled            = var.rdb_backup_enabled
    rdb_backup_frequency          = var.rdb_backup_enabled ? var.rdb_backup_frequency : null
    rdb_backup_max_snapshot_count = var.rdb_backup_enabled ? var.rdb_backup_max_snapshot_count : null
    rdb_storage_connection_string = var.rdb_backup_enabled ? var.rdb_storage_connection_string : null
  }

  zones = var.zones

  lifecycle {
    prevent_destroy = false
    ignore_changes  = [redis_configuration[0].rdb_storage_connection_string]
  }
}

resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${var.redis_cache_name}"
  target_resource_id         = azurerm_redis_cache.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "ConnectedClientList"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
