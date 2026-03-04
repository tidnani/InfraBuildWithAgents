terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id

  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

module "resource_group" {
  source   = "../../modules/resource_group"
  name     = "${var.prefix}-rg-dev"
  location = var.location
  tags     = var.tags
}

module "monitoring" {
  source              = "../../modules/monitoring"
  workspace_name      = "${var.prefix}-law-dev"
  app_insights_name   = "${var.prefix}-ai-dev"
  resource_group_name = module.resource_group.name
  location            = var.location
  action_group_name   = "${var.prefix}-ag-dev"
  alert_email         = var.alert_email
  tags                = var.tags
}

module "networking" {
  source                         = "../../modules/networking"
  vnet_name                      = "${var.prefix}-vnet-dev"
  vnet_address_space             = var.vnet_address_space
  app_service_subnet_prefix      = var.app_service_subnet_prefix
  private_endpoint_subnet_prefix = var.private_endpoint_subnet_prefix
  resource_group_name            = module.resource_group.name
  location                       = var.location
  tags                           = var.tags
}

module "key_vault" {
  source                     = "../../modules/key_vault"
  key_vault_name             = "${var.prefix}-kv-dev"
  resource_group_name        = module.resource_group.name
  location                   = var.location
  subnet_id                  = module.networking.private_endpoint_subnet_id
  private_dns_zone_id        = module.networking.key_vault_private_dns_zone_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tenant_id                  = var.tenant_id
  tags                       = var.tags
}

module "app_service" {
  source                         = "../../modules/app_service"
  app_name                       = "${var.prefix}-app-dev"
  resource_group_name            = module.resource_group.name
  location                       = var.location
  app_service_plan_name          = "${var.prefix}-asp-dev"
  subnet_id                      = module.networking.app_service_subnet_id
  key_vault_uri                  = module.key_vault.key_vault_uri
  app_insights_connection_string = module.monitoring.app_insights_connection_string
  app_insights_key               = module.monitoring.app_insights_instrumentation_key
  log_analytics_workspace_id     = module.monitoring.log_analytics_workspace_id
  health_check_path              = var.health_check_path
  allowed_front_door_header      = var.front_door_profile_id
  tags                           = var.tags
}

module "front_door" {
  source              = "../../modules/front_door"
  profile_name        = "${var.prefix}-afd-dev"
  endpoint_name       = "${var.prefix}-ep-dev"
  resource_group_name = module.resource_group.name
  origins = [
    {
      name                   = "app-service-${var.location}"
      host_name              = module.app_service.app_service_default_hostname
      private_link_location  = var.location
      private_link_target_id = module.app_service.app_service_id
    }
  ]
  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "cpu" {
  name                = "${var.prefix}-cpu-alert-dev"
  resource_group_name = module.resource_group.name
  scopes              = [module.app_service.app_service_plan_id]
  description         = "Alert when App Service Plan CPU utilisation exceeds 80%."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "memory" {
  name                = "${var.prefix}-memory-alert-dev"
  resource_group_name = module.resource_group.name
  scopes              = [module.app_service.app_service_plan_id]
  description         = "Alert when App Service Plan memory utilisation exceeds 85%."
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "http_5xx" {
  name                = "${var.prefix}-http5xx-alert-dev"
  resource_group_name = module.resource_group.name
  scopes              = [module.app_service.app_service_id]
  description         = "Alert when App Service HTTP 5xx error count exceeds threshold."
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = var.http_5xx_threshold
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }
}
