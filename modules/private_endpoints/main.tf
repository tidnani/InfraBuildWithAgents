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

  dns_zone_configs = {
    "sql"      = "privatelink.database.windows.net"
    "redis"    = "privatelink.redis.cache.windows.net"
    "keyvault" = "privatelink.vaultcore.azure.net"
  }

  # Map subresource names to the internal DNS zone key
  subresource_to_dns_key = {
    "sqlServer"  = "sql"
    "redisCache" = "redis"
    "vault"      = "keyvault"
  }

  # Map of DNS zone key -> zone ID (only populated when create_dns_zones = true)
  internal_dns_zone_ids = var.create_dns_zones ? {
    "sql"      = azurerm_private_dns_zone.sql[0].id
    "redis"    = azurerm_private_dns_zone.redis[0].id
    "keyvault" = azurerm_private_dns_zone.keyvault[0].id
  } : {}
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoints

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.value.subnet_id
  tags                = local.tags

  private_service_connection {
    name                           = "${each.value.name}-psc"
    private_connection_resource_id = each.value.private_connection_resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = (var.create_dns_zones || length(each.value.private_dns_zone_ids) > 0) ? [1] : []
    content {
      name = "${each.value.name}-dns-group"
      private_dns_zone_ids = var.create_dns_zones ? compact([
        for sr in each.value.subresource_names :
        lookup(local.internal_dns_zone_ids, lookup(local.subresource_to_dns_key, sr, ""), "")
      ]) : each.value.private_dns_zone_ids
    }
  }
}

resource "azurerm_private_dns_zone" "sql" {
  count               = var.create_dns_zones ? 1 : 0
  name                = local.dns_zone_configs["sql"]
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone" "redis" {
  count               = var.create_dns_zones ? 1 : 0
  name                = local.dns_zone_configs["redis"]
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone" "keyvault" {
  count               = var.create_dns_zones ? 1 : 0
  name                = local.dns_zone_configs["keyvault"]
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  count                 = var.create_dns_zones ? 1 : 0
  name                  = "vnet-link-sql"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.sql[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  count                 = var.create_dns_zones ? 1 : 0
  name                  = "vnet-link-redis"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.redis[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  count                 = var.create_dns_zones ? 1 : 0
  name                  = "vnet-link-keyvault"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault[0].name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
  tags                  = local.tags
}
