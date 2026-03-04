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

locals {
  regions = {
    eastus = {
      location   = "eastus"
      short_name = "eus"
      vnet_cidr  = "10.20.0.0/16"
      app_snet   = "10.20.1.0/24"
      pe_snet    = "10.20.2.0/24"
    }
    westus2 = {
      location   = "westus2"
      short_name = "wus"
      vnet_cidr  = "10.21.0.0/16"
      app_snet   = "10.21.1.0/24"
      pe_snet    = "10.21.2.0/24"
    }
  }
}

module "resource_group" {
  for_each = local.regions

  source   = "../../modules/resource_group"
  name     = "${var.prefix}-rg-${each.value.short_name}-prod"
  location = each.value.location
  tags     = var.tags
}

module "monitoring" {
  for_each = local.regions

  source              = "../../modules/monitoring"
  workspace_name      = "${var.prefix}-law-${each.value.short_name}-prod"
  app_insights_name   = "${var.prefix}-ai-${each.value.short_name}-prod"
  resource_group_name = module.resource_group[each.key].name
  location            = each.value.location
  action_group_name   = "${var.prefix}-ag-${each.value.short_name}-prod"
  alert_email         = var.alert_email
  tags                = var.tags
}

module "networking" {
  for_each = local.regions

  source                         = "../../modules/networking"
  vnet_name                      = "${var.prefix}-vnet-${each.value.short_name}-prod"
  vnet_address_space             = [each.value.vnet_cidr]
  app_service_subnet_prefix      = each.value.app_snet
  private_endpoint_subnet_prefix = each.value.pe_snet
  resource_group_name            = module.resource_group[each.key].name
  location                       = each.value.location
  tags                           = var.tags
}

module "key_vault" {
  for_each = local.regions

  source                     = "../../modules/key_vault"
  key_vault_name             = "${var.prefix}-kv-${each.value.short_name}-prod"
  resource_group_name        = module.resource_group[each.key].name
  location                   = each.value.location
  subnet_id                  = module.networking[each.key].private_endpoint_subnet_id
  private_dns_zone_id        = module.networking[each.key].key_vault_private_dns_zone_id
  log_analytics_workspace_id = module.monitoring[each.key].log_analytics_workspace_id
  tenant_id                  = var.tenant_id
  tags                       = var.tags
}

module "app_service" {
  for_each = local.regions

  source                         = "../../modules/app_service"
  app_name                       = "${var.prefix}-app-${each.value.short_name}-prod"
  resource_group_name            = module.resource_group[each.key].name
  location                       = each.value.location
  app_service_plan_name          = "${var.prefix}-asp-${each.value.short_name}-prod"
  subnet_id                      = module.networking[each.key].app_service_subnet_id
  key_vault_uri                  = module.key_vault[each.key].key_vault_uri
  app_insights_connection_string = module.monitoring[each.key].app_insights_connection_string
  app_insights_key               = module.monitoring[each.key].app_insights_instrumentation_key
  log_analytics_workspace_id     = module.monitoring[each.key].log_analytics_workspace_id
  health_check_path              = var.health_check_path
  allowed_front_door_header      = var.front_door_profile_id
  tags                           = var.tags
}

module "front_door" {
  source              = "../../modules/front_door"
  profile_name        = "${var.prefix}-afd-prod"
  endpoint_name       = "${var.prefix}-ep-prod"
  resource_group_name = module.resource_group["eastus"].name
  origins = [
    for region_key, region in local.regions : {
      name                   = "app-service-${region.short_name}"
      host_name              = module.app_service[region_key].app_service_default_hostname
      private_link_location  = region.location
      private_link_target_id = module.app_service[region_key].app_service_id
    }
  ]
  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "cpu" {
  for_each = local.regions

  name                = "${var.prefix}-cpu-alert-${each.value.short_name}-prod"
  resource_group_name = module.resource_group[each.key].name
  scopes              = [module.app_service[each.key].app_service_plan_id]
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
    action_group_id = module.monitoring[each.key].action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "memory" {
  for_each = local.regions

  name                = "${var.prefix}-memory-alert-${each.value.short_name}-prod"
  resource_group_name = module.resource_group[each.key].name
  scopes              = [module.app_service[each.key].app_service_plan_id]
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
    action_group_id = module.monitoring[each.key].action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "http_5xx" {
  for_each = local.regions

  name                = "${var.prefix}-http5xx-alert-${each.value.short_name}-prod"
  resource_group_name = module.resource_group[each.key].name
  scopes              = [module.app_service[each.key].app_service_id]
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
    action_group_id = module.monitoring[each.key].action_group_id
  }
}
