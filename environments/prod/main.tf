locals {
  environment = "prod"
  location    = var.location
  name_prefix = "${var.project_name}-${local.environment}"

  common_tags = {
    environment = local.environment
    project     = var.project_name
    owner       = var.owner_tag
    cost_center = var.cost_center_tag
  }
}

module "resource_group" {
  source = "../../modules/resource_group"

  name     = "rg-${local.name_prefix}-${var.location_short}"
  location = local.location
  tags     = local.common_tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  workspace_name      = "log-${local.name_prefix}-001"
  app_insights_name   = "appi-${local.name_prefix}-001"
  location            = local.location
  resource_group_name = module.resource_group.name
  retention_in_days   = var.log_retention_in_days
  tags                = local.common_tags
}

module "networking" {
  source = "../../modules/networking"

  vnet_name           = "vnet-${local.name_prefix}-001"
  address_space       = [var.vnet_address_space]
  location            = local.location
  resource_group_name = module.resource_group.name
  tags                = local.common_tags

  subnets = {
    app_service_subnet = {
      address_prefix = var.app_service_subnet_prefix
      service_delegation = {
        name    = "Microsoft.Web/serverFarms"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
    private_endpoint_subnet = {
      address_prefix     = var.private_endpoint_subnet_prefix
      service_delegation = null
    }
    management_subnet = {
      address_prefix     = var.management_subnet_prefix
      service_delegation = null
    }
  }
}

module "key_vault" {
  source = "../../modules/key_vault"

  key_vault_name                = "kv-${local.name_prefix}-001"
  location                      = local.location
  resource_group_name           = module.resource_group.name
  tenant_id                     = var.tenant_id
  sku_name                      = "premium"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = false
  log_analytics_workspace_id    = module.monitoring.log_analytics_workspace_id
  tags                          = local.common_tags

  network_acls = {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = []
    virtual_network_subnet_ids = [module.networking.subnet_ids["app_service_subnet"]]
  }
}

module "app_service" {
  source = "../../modules/app_service"

  app_service_plan_name          = "asp-${local.name_prefix}-001"
  app_service_name               = "app-${local.name_prefix}-001"
  location                       = local.location
  resource_group_name            = module.resource_group.name
  sku_name                       = "P3v3"
  zone_balancing_enabled         = true
  subnet_id                      = module.networking.subnet_ids["app_service_subnet"]
  log_analytics_workspace_id     = module.monitoring.log_analytics_workspace_id
  app_insights_connection_string = module.monitoring.app_insights_connection_string
  autoscale_min_capacity         = 3
  autoscale_max_capacity         = 10
  autoscale_default_capacity     = 3
  tags                           = local.common_tags

  app_settings = {
    ASPNETCORE_ENVIRONMENT = "Production"
  }
}

module "sql_database" {
  source = "../../modules/sql_database"

  server_name                  = "sql-${local.name_prefix}-001"
  database_name                = "sqldb-${local.name_prefix}-001"
  location                     = local.location
  resource_group_name          = module.resource_group.name
  administrator_login          = var.sql_admin_login
  administrator_login_password = var.sql_admin_password
  azuread_admin_login          = var.azuread_admin_login
  azuread_admin_object_id      = var.azuread_admin_object_id
  sku_name                     = "BC_Gen5_4"
  zone_redundant               = true
  log_analytics_workspace_id   = module.monitoring.log_analytics_workspace_id
  tags                         = local.common_tags
}

module "redis_cache" {
  source = "../../modules/redis_cache"

  redis_cache_name              = "redis-${local.name_prefix}-001"
  location                      = local.location
  resource_group_name           = module.resource_group.name
  sku_name                      = "Premium"
  family                        = "P"
  capacity                      = 1
  zones                         = ["1", "2", "3"]
  rdb_backup_enabled            = true
  rdb_backup_frequency          = 60
  rdb_backup_max_snapshot_count = 1
  rdb_storage_connection_string = var.redis_backup_storage_connection_string
  log_analytics_workspace_id    = module.monitoring.log_analytics_workspace_id
  tags                          = local.common_tags
}

module "private_endpoints" {
  source = "../../modules/private_endpoints"

  resource_group_name = module.resource_group.name
  location            = local.location
  virtual_network_id  = module.networking.vnet_id
  create_dns_zones    = true
  tags                = local.common_tags

  private_endpoints = {
    sql = {
      name                           = "pe-sql-${local.name_prefix}-001"
      subnet_id                      = module.networking.subnet_ids["private_endpoint_subnet"]
      private_connection_resource_id = module.sql_database.server_id
      subresource_names              = ["sqlServer"]
    }
    redis = {
      name                           = "pe-redis-${local.name_prefix}-001"
      subnet_id                      = module.networking.subnet_ids["private_endpoint_subnet"]
      private_connection_resource_id = module.redis_cache.id
      subresource_names              = ["redisCache"]
    }
    keyvault = {
      name                           = "pe-kv-${local.name_prefix}-001"
      subnet_id                      = module.networking.subnet_ids["private_endpoint_subnet"]
      private_connection_resource_id = module.key_vault.id
      subresource_names              = ["vault"]
    }
  }
}

module "front_door" {
  source = "../../modules/front_door"

  front_door_name            = "afd-${local.name_prefix}-001"
  resource_group_name        = module.resource_group.name
  waf_policy_name            = "wafpolicy${replace(local.name_prefix, "-", "")}001"
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.common_tags

  origins = [
    {
      name               = "app-origin-primary"
      host_name          = module.app_service.default_hostname
      origin_host_header = module.app_service.default_hostname
      priority           = 1
      weight             = 1000
    }
  ]
}
