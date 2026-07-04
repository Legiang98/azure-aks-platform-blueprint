resource "azurerm_mssql_server" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.server_version
  minimum_tls_version           = var.minimum_tls_version
  public_network_access_enabled = var.public_network_access_enabled
  administrator_login           = var.administrator_login
  administrator_login_password  = var.administrator_login_password
  tags                          = var.tags

  dynamic "azuread_administrator" {
    for_each = var.azuread_administrator == null ? [] : [var.azuread_administrator]

    content {
      login_username              = azuread_administrator.value.login_username
      object_id                   = azuread_administrator.value.object_id
      tenant_id                   = azuread_administrator.value.tenant_id
      azuread_authentication_only = azuread_administrator.value.azuread_authentication_only
    }
  }
}

resource "azurerm_mssql_elasticpool" "this" {
  for_each = var.elastic_pools

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_mssql_server.this.name
  max_size_gb         = each.value.max_size_gb
  license_type        = try(each.value.license_type, null)
  zone_redundant      = try(each.value.zone_redundant, false)
  tags                = merge(var.tags, try(each.value.tags, {}))

  sku {
    name     = each.value.sku.name
    tier     = each.value.sku.tier
    family   = try(each.value.sku.family, null)
    capacity = each.value.sku.capacity
  }

  per_database_settings {
    min_capacity = each.value.per_database_settings.min_capacity
    max_capacity = each.value.per_database_settings.max_capacity
  }
}

resource "azurerm_mssql_database" "this" {
  for_each = var.databases

  name                 = each.value.name
  server_id            = azurerm_mssql_server.this.id
  collation            = try(each.value.collation, "SQL_Latin1_General_CP1_CI_AS")
  max_size_gb          = try(each.value.max_size_gb, 32)
  elastic_pool_id      = try(azurerm_mssql_elasticpool.this[each.value.elastic_pool_key].id, null)
  sku_name             = try(each.value.elastic_pool_key, null) == null ? try(each.value.sku_name, "Basic") : null
  storage_account_type = try(each.value.storage_account_type, "Local")
  zone_redundant       = try(each.value.zone_redundant, false)
  tags                 = merge(var.tags, try(each.value.tags, {}))
}
