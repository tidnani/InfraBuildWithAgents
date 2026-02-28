environment        = "staging"
location           = "eastus2"
secondary_location = "westus2"
application_name   = "missioncritical"

vnet_address_space           = ["10.1.0.0/16"]
app_service_sku_name         = "P2v3"
app_service_plan_capacity    = 2
sql_admin_login              = "sqladmin"
sql_sku_name                 = "BC_Gen5_2"
redis_capacity               = 1
redis_family                 = "P"
redis_sku_name               = "Premium"
key_vault_sku_name           = "premium"
log_analytics_retention_days = 60
waf_mode                     = "Prevention"

tags = {
  environment = "staging"
  cost_center = "engineering"
  team        = "platform"
}
