environment        = "dev"
location           = "eastus2"
secondary_location = "westus2"
application_name   = "missioncritical"

vnet_address_space           = ["10.0.0.0/16"]
app_service_sku_name         = "P1v3"
app_service_plan_capacity    = 1
sql_admin_login              = "sqladmin"
sql_sku_name                 = "GP_Gen5_2"
redis_capacity               = 1
redis_family                 = "C"
redis_sku_name               = "Standard"
key_vault_sku_name           = "standard"
log_analytics_retention_days = 30
waf_mode                     = "Detection"

tags = {
  environment = "dev"
  cost_center = "engineering"
  team        = "platform"
}
