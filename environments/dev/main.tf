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
    storage_account_name = "tfstatedev"
    container_name       = "tfstate"
    key                  = "mission-critical/dev/terraform.tfstate"
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
  environment = "dev"
  prefix      = "${var.project_name}-${local.environment}"

  common_tags = merge(var.tags, {
    Environment = local.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  })
}

# Resource Group
module "resource_group" {
  source = "../../modules/resource_group"

  name     = "${local.prefix}-rg"
  location = var.primary_location
  tags     = local.common_tags
}

# Monitoring base: workspace + app insights + action group (no alert IDs yet)
# These outputs feed into app_service, so they must be created first.
module "monitoring" {
  source = "../../modules/monitoring"

  log_analytics_workspace_name = "${local.prefix}-law"
  app_insights_name            = "${local.prefix}-ai"
  location                     = var.primary_location
  resource_group_name          = module.resource_group.name
  log_retention_days           = 30
  app_insights_retention_days  = 30
  daily_data_cap_gb            = 5
  action_group_name            = "${local.prefix}-action-group"
  action_group_short_name      = "devactions"
  alert_name_prefix            = local.prefix
  alert_email_receivers        = var.alert_email_receivers
  # Leave resource IDs null so that metric alerts are skipped at this stage.
  # The alerts below reference the deployed resources directly.
  app_service_plan_id   = null
  web_app_id            = null
  front_door_profile_id = null
  create_dashboard      = false
  tags                  = local.common_tags

  depends_on = [module.resource_group]
}

# Networking
module "networking" {
  source = "../../modules/networking"

  vnet_name           = "${local.prefix}-vnet"
  location            = var.primary_location
  resource_group_name = module.resource_group.name
  vnet_address_space  = ["10.0.0.0/16"]

  app_service_subnet_name          = "app-service-integration"
  app_service_subnet_prefixes      = ["10.0.1.0/24"]
  private_endpoint_subnet_name     = "private-endpoints"
  private_endpoint_subnet_prefixes = ["10.0.2.0/24"]

  tags = local.common_tags

  depends_on = [module.resource_group]
}

# App Service (depends on monitoring outputs for workspace/app insights)
module "app_service" {
  source = "../../modules/app_service"

  app_service_plan_name           = "${local.prefix}-asp"
  web_app_name                    = "${local.prefix}-app"
  location                        = var.primary_location
  resource_group_name             = module.resource_group.name
  sku_name                        = "P1v3"
  zone_balancing_enabled          = false # Disabled for dev to reduce cost
  worker_count                    = 1
  vnet_integration_subnet_id      = module.networking.app_service_subnet_id
  private_endpoint_subnet_id      = module.networking.private_endpoint_subnet_id
  app_service_private_dns_zone_id = module.networking.app_service_private_dns_zone_id
  log_analytics_workspace_id      = module.monitoring.log_analytics_workspace_id
  app_insights_connection_string  = module.monitoring.app_insights_connection_string
  health_check_path               = "/health"
  node_version                    = var.node_version
  autoscale_min_capacity          = 1
  autoscale_max_capacity          = 3
  autoscale_default_capacity      = 1
  tags                            = local.common_tags

  depends_on = [module.networking, module.monitoring]
}

# Key Vault (depends on app_service for principal ID)
module "key_vault" {
  source = "../../modules/key_vault"

  name                          = "${var.project_name}kvdev"
  location                      = var.primary_location
  resource_group_name           = module.resource_group.name
  private_endpoint_subnet_id    = module.networking.private_endpoint_subnet_id
  key_vault_private_dns_zone_id = module.networking.key_vault_private_dns_zone_id
  log_analytics_workspace_id    = module.monitoring.log_analytics_workspace_id
  web_app_principal_ids         = [module.app_service.web_app_principal_id]
  tags                          = local.common_tags

  depends_on = [module.networking, module.monitoring, module.app_service]
}

# Azure Front Door (depends on app_service for origin hostname)
module "front_door" {
  source = "../../modules/front_door"

  front_door_name            = "${local.prefix}-afd"
  resource_group_name        = module.resource_group.name
  sku_name                   = "Premium_AzureFrontDoor"
  endpoint_name              = "${local.prefix}-endpoint"
  waf_policy_name            = "${var.project_name}wafdev"
  waf_mode                   = "Detection" # Use Detection in dev
  origin_group_name          = "${local.prefix}-origin-group"
  health_probe_path          = "/health"
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.common_tags

  origins = {
    "primary" = {
      host_name                = module.app_service.web_app_default_hostname
      priority                 = 1
      weight                   = 1000
      private_link_resource_id = module.app_service.web_app_id
      private_link_location    = var.primary_location
    }
  }

  depends_on = [module.app_service, module.monitoring]
}

# Metric alerts wired to the deployed resources (no cycle: monitoring module
# already created the workspace and action group above)
resource "azurerm_monitor_metric_alert" "app_service_cpu" {
  name                = "${local.prefix}-high-cpu"
  resource_group_name = module.resource_group.name
  scopes              = [module.app_service.app_service_plan_id]
  description         = "Alert when App Service Plan CPU exceeds 85%."
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

resource "azurerm_monitor_metric_alert" "web_app_http5xx" {
  name                = "${local.prefix}-http5xx"
  resource_group_name = module.resource_group.name
  scopes              = [module.app_service.web_app_id]
  description         = "Alert when HTTP 5xx errors exceed 10 in a 15-minute window."
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = local.common_tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = module.monitoring.action_group_id
  }
}

