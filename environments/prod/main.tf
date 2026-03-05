terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateprod"
    container_name       = "tfstate"
    key                  = "mission-critical/prod/terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  use_oidc = true
}

# Local values for environment-specific naming
locals {
  environment = "prod"
  prefix      = "${var.project_name}-${local.environment}"

  common_tags = merge(var.tags, {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })
}

# Primary Resource Group
module "resource_group_primary" {
  source = "../../modules/resource_group"

  name     = "${local.prefix}-primary-rg"
  location = var.primary_location
  tags     = local.common_tags
}

# Secondary Resource Group (for geo-redundancy)
module "resource_group_secondary" {
  source = "../../modules/resource_group"

  name     = "${local.prefix}-secondary-rg"
  location = var.secondary_location
  tags     = local.common_tags
}

# Monitoring (primary region - workspace shared across regions)
module "monitoring" {
  source = "../../modules/monitoring"

  log_analytics_workspace_name = "${local.prefix}-law"
  app_insights_name            = "${local.prefix}-ai"
  location                     = var.primary_location
  resource_group_name          = module.resource_group_primary.name
  log_retention_days           = 90
  app_insights_retention_days  = 90
  daily_data_cap_gb            = 20
  action_group_name            = "${local.prefix}-action-group"
  action_group_short_name      = "prodactions"
  alert_name_prefix            = local.prefix
  alert_email_receivers        = var.alert_email_receivers
  app_service_plan_id          = null
  web_app_id                   = null
  front_door_profile_id        = null
  create_dashboard             = true
  tags                         = local.common_tags

  depends_on = [module.resource_group_primary]
}

# Primary Networking
module "networking_primary" {
  source = "../../modules/networking"

  vnet_name           = "${local.prefix}-primary-vnet"
  location            = var.primary_location
  resource_group_name = module.resource_group_primary.name
  vnet_address_space  = ["10.1.0.0/16"]

  app_service_subnet_name          = "app-service-integration"
  app_service_subnet_prefixes      = ["10.1.1.0/24"]
  private_endpoint_subnet_name     = "private-endpoints"
  private_endpoint_subnet_prefixes = ["10.1.2.0/24"]

  tags = local.common_tags

  depends_on = [module.resource_group_primary]
}

# Secondary Networking
module "networking_secondary" {
  source = "../../modules/networking"

  vnet_name           = "${local.prefix}-secondary-vnet"
  location            = var.secondary_location
  resource_group_name = module.resource_group_secondary.name
  vnet_address_space  = ["10.2.0.0/16"]

  app_service_subnet_name          = "app-service-integration"
  app_service_subnet_prefixes      = ["10.2.1.0/24"]
  private_endpoint_subnet_name     = "private-endpoints"
  private_endpoint_subnet_prefixes = ["10.2.2.0/24"]

  tags = local.common_tags

  depends_on = [module.resource_group_secondary]
}

# Primary App Service (zone-redundant)
module "app_service_primary" {
  source = "../../modules/app_service"

  app_service_plan_name           = "${local.prefix}-primary-asp"
  web_app_name                    = "${local.prefix}-primary-app"
  location                        = var.primary_location
  resource_group_name             = module.resource_group_primary.name
  sku_name                        = "P1v3"
  zone_balancing_enabled          = true
  worker_count                    = 3
  vnet_integration_subnet_id      = module.networking_primary.app_service_subnet_id
  private_endpoint_subnet_id      = module.networking_primary.private_endpoint_subnet_id
  app_service_private_dns_zone_id = module.networking_primary.app_service_private_dns_zone_id
  log_analytics_workspace_id      = module.monitoring.log_analytics_workspace_id
  app_insights_connection_string  = module.monitoring.app_insights_connection_string
  health_check_path               = "/health"
  node_version                    = var.node_version
  autoscale_min_capacity          = 3
  autoscale_max_capacity          = 20
  autoscale_default_capacity      = 3
  tags                            = local.common_tags

  depends_on = [module.networking_primary, module.monitoring]
}

# Secondary App Service (zone-redundant)
module "app_service_secondary" {
  source = "../../modules/app_service"

  app_service_plan_name           = "${local.prefix}-secondary-asp"
  web_app_name                    = "${local.prefix}-secondary-app"
  location                        = var.secondary_location
  resource_group_name             = module.resource_group_secondary.name
  sku_name                        = "P1v3"
  zone_balancing_enabled          = true
  worker_count                    = 3
  vnet_integration_subnet_id      = module.networking_secondary.app_service_subnet_id
  private_endpoint_subnet_id      = module.networking_secondary.private_endpoint_subnet_id
  app_service_private_dns_zone_id = module.networking_secondary.app_service_private_dns_zone_id
  log_analytics_workspace_id      = module.monitoring.log_analytics_workspace_id
  app_insights_connection_string  = module.monitoring.app_insights_connection_string
  health_check_path               = "/health"
  node_version                    = var.node_version
  autoscale_min_capacity          = 3
  autoscale_max_capacity          = 20
  autoscale_default_capacity      = 3
  tags                            = local.common_tags

  depends_on = [module.networking_secondary, module.monitoring]
}

# Primary Key Vault
module "key_vault_primary" {
  source = "../../modules/key_vault"

  name                          = "${var.project_name}kvprod1"
  location                      = var.primary_location
  resource_group_name           = module.resource_group_primary.name
  private_endpoint_subnet_id    = module.networking_primary.private_endpoint_subnet_id
  key_vault_private_dns_zone_id = module.networking_primary.key_vault_private_dns_zone_id
  log_analytics_workspace_id    = module.monitoring.log_analytics_workspace_id
  web_app_principal_ids = [
    module.app_service_primary.web_app_principal_id,
    module.app_service_secondary.web_app_principal_id,
  ]
  tags = local.common_tags

  depends_on = [module.networking_primary, module.monitoring, module.app_service_primary, module.app_service_secondary]
}

# Azure Front Door (multi-origin, premium for private link)
module "front_door" {
  source = "../../modules/front_door"

  front_door_name            = "${local.prefix}-afd"
  resource_group_name        = module.resource_group_primary.name
  sku_name                   = "Premium_AzureFrontDoor"
  endpoint_name              = "${local.prefix}-endpoint"
  waf_policy_name            = "${var.project_name}wafprod"
  waf_mode                   = "Prevention" # Prevention mode in production
  origin_group_name          = "${local.prefix}-origin-group"
  health_probe_path          = "/health"
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.common_tags

  origins = {
    "primary" = {
      host_name                = module.app_service_primary.web_app_default_hostname
      priority                 = 1
      weight                   = 1000
      private_link_resource_id = module.app_service_primary.web_app_id
      private_link_location    = var.primary_location
    }
    "secondary" = {
      host_name                = module.app_service_secondary.web_app_default_hostname
      priority                 = 2
      weight                   = 1000
      private_link_resource_id = module.app_service_secondary.web_app_id
      private_link_location    = var.secondary_location
    }
  }

  depends_on = [module.app_service_primary, module.app_service_secondary, module.monitoring]
}

# Metric alerts for production
resource "azurerm_monitor_metric_alert" "app_service_cpu_primary" {
  name                = "${local.prefix}-primary-high-cpu"
  resource_group_name = module.resource_group_primary.name
  scopes              = [module.app_service_primary.app_service_plan_id]
  description         = "Alert when primary App Service Plan CPU exceeds 85%."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "app_service_cpu_secondary" {
  name                = "${local.prefix}-secondary-high-cpu"
  resource_group_name = module.resource_group_secondary.name
  scopes              = [module.app_service_secondary.app_service_plan_id]
  description         = "Alert when secondary App Service Plan CPU exceeds 85%."
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Web/serverfarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 85
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "web_app_http5xx_primary" {
  name                = "${local.prefix}-primary-http5xx"
  resource_group_name = module.resource_group_primary.name
  scopes              = [module.app_service_primary.web_app_id]
  description         = "Alert when primary web app HTTP 5xx errors exceed 5 per 15-minute window."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 5
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }
}

resource "azurerm_monitor_metric_alert" "front_door_origin_health" {
  name                = "${local.prefix}-fd-origin-health"
  resource_group_name = module.resource_group_primary.name
  scopes              = [module.front_door.front_door_id]
  description         = "Alert when Front Door origin health drops below 100%."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Cdn/profiles"
    metric_name      = "OriginHealthPercentage"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 100
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }
}
