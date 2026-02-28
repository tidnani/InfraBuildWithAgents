locals {
  common_tags = merge(
    {
      environment  = var.environment
      application  = var.application_name
      managed_by   = "terraform"
      architecture = "mission-critical"
    },
    var.tags
  )

  name_prefix = "${var.application_name}-${var.environment}"
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  name_prefix         = local.name_prefix
  retention_days      = var.log_analytics_retention_days
  tags                = local.common_tags
}

module "networking" {
  source = "./modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  name_prefix         = local.name_prefix
  vnet_address_space  = var.vnet_address_space
  tags                = local.common_tags

  depends_on = [module.monitoring]
}

module "key_vault" {
  source = "./modules/key-vault"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  name_prefix                = local.name_prefix
  sku_name                   = var.key_vault_sku_name
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_id        = module.networking.keyvault_private_dns_zone_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  sql_admin_password         = var.sql_admin_password
  tags                       = local.common_tags

  depends_on = [module.networking]
}

module "sql_database" {
  source = "./modules/sql-database"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  secondary_location         = var.secondary_location
  name_prefix                = local.name_prefix
  sku_name                   = var.sql_sku_name
  admin_login                = var.sql_admin_login
  admin_password             = var.sql_admin_password
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_id        = module.networking.sql_private_dns_zone_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  key_vault_id               = module.key_vault.key_vault_id
  tags                       = local.common_tags

  depends_on = [module.networking, module.key_vault]
}

module "redis_cache" {
  source = "./modules/redis-cache"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  name_prefix                = local.name_prefix
  capacity                   = var.redis_capacity
  family                     = var.redis_family
  sku_name                   = var.redis_sku_name
  private_endpoint_subnet_id = module.networking.private_endpoint_subnet_id
  private_dns_zone_id        = module.networking.redis_private_dns_zone_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  key_vault_id               = module.key_vault.key_vault_id
  tags                       = local.common_tags

  depends_on = [module.networking, module.key_vault]
}

module "app_service" {
  source = "./modules/app-service"

  resource_group_name              = azurerm_resource_group.main.name
  location                         = var.location
  name_prefix                      = local.name_prefix
  sku_name                         = var.app_service_sku_name
  plan_capacity                    = var.app_service_plan_capacity
  vnet_integration_subnet_id       = module.networking.app_service_subnet_id
  private_endpoint_subnet_id       = module.networking.private_endpoint_subnet_id
  private_dns_zone_id              = module.networking.sites_private_dns_zone_id
  key_vault_id                     = module.key_vault.key_vault_id
  sql_connection_string_uri        = module.sql_database.connection_string_key_vault_uri
  redis_connection_string_uri      = module.redis_cache.connection_string_key_vault_uri
  log_analytics_workspace_id       = module.monitoring.log_analytics_workspace_id
  app_insights_connection_string   = module.monitoring.app_insights_connection_string
  app_insights_instrumentation_key = module.monitoring.app_insights_instrumentation_key
  tags                             = local.common_tags

  depends_on = [module.networking, module.key_vault, module.sql_database, module.redis_cache, module.monitoring]
}

module "front_door" {
  source = "./modules/front-door"

  resource_group_name        = azurerm_resource_group.main.name
  location                   = var.location
  name_prefix                = local.name_prefix
  app_service_hostname       = module.app_service.app_service_default_hostname
  app_service_resource_id    = module.app_service.app_service_id
  waf_mode                   = var.waf_mode
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.common_tags

  depends_on = [module.app_service]
}
