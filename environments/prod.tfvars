environment        = "prod"
location           = "eastus2"
secondary_location = "westus2"
application_name   = "missioncritical"

vnet_address_space           = ["10.2.0.0/16"]
app_service_sku_name         = "P3v3"
app_service_plan_capacity    = 3
sql_admin_login              = "sqladmin"
sql_sku_name                 = "BC_Gen5_4"
redis_capacity               = 1
redis_family                 = "P"
redis_sku_name               = "Premium"
key_vault_sku_name           = "premium"
log_analytics_retention_days = 90
waf_mode                     = "Prevention"

tags = {
  environment = "prod"
  cost_center = "engineering"
  team        = "platform"
  criticality = "high"
  sla         = "99.99"
}
