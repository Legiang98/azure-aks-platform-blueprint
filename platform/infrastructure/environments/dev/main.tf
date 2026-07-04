data "azurerm_client_config" "current" {}

locals {
  tags = try(var.platform.tags, {})

  primary_resource_group_key = "platform"
  primary_sql_server_key     = "platform"
}

module "resource_group" {
  for_each = try(var.platform.resource_groups, {})
  source   = "../../modules/resource-group"

  name     = each.value.name
  location = each.value.location
  tags     = merge(local.tags, try(each.value.tags, {}))
}

module "azure_sql" {
  for_each = try(var.platform.azure_sql_servers, {})
  source   = "../../modules/azure-sql"

  name                          = each.value.name
  resource_group_name           = module.resource_group[each.value.resource_group_key].name
  location                      = module.resource_group[each.value.resource_group_key].location
  server_version                = try(each.value.server_version, "12.0")
  minimum_tls_version           = try(each.value.minimum_tls_version, "1.2")
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)
  administrator_login           = try(each.value.administrator_login, null)
  administrator_login_password  = try(each.value.administrator_login_password, null)
  elastic_pools                 = try(each.value.elastic_pools, {})
  databases                     = try(each.value.databases, {})
  tags                          = merge(local.tags, try(each.value.tags, {}))

  azuread_administrator = try(each.value.azuread_administrator.use_current_client, false) ? {
    login_username              = try(each.value.azuread_administrator.login_username, "current-client")
    object_id                   = data.azurerm_client_config.current.object_id
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    azuread_authentication_only = try(each.value.azuread_administrator.azuread_authentication_only, true)
  } : try(each.value.azuread_administrator, null)
}

module "managed_identity" {
  for_each = try(var.platform.managed_identities, {})
  source   = "../../modules/managed-identity"

  name                = each.value.name
  resource_group_name = module.resource_group[each.value.resource_group_key].name
  location            = module.resource_group[each.value.resource_group_key].location
  role_assignments = merge(
    try(each.value.role_assignments, {}),
    each.key == "github_actions" ? {
      acr_push = {
        scope                = module.container_registry[try(each.value.acr_key, "platform")].id
        role_definition_name = "AcrPush"
      }
    } : {}
  )
  federated_identity_credentials = try(each.value.federated_identity_credentials, {})
  tags                           = merge(local.tags, try(each.value.tags, {}))
}

module "container_registry" {
  for_each = try(var.platform.container_registries, {})
  source   = "../../modules/container-registry"

  name                          = each.value.name
  resource_group_name           = module.resource_group[each.value.resource_group_key].name
  location                      = module.resource_group[each.value.resource_group_key].location
  sku                           = try(each.value.sku, "Basic")
  admin_enabled                 = try(each.value.admin_enabled, false)
  public_network_access_enabled = try(each.value.public_network_access_enabled, true)
  pull_role_assignment_enabled  = try(each.value.pull_role_assignment_enabled, false)
  pull_principal_id             = try(each.value.pull_principal_id, null)
  tags                          = merge(local.tags, try(each.value.tags, {}))
}

# Disabled for the current SQL-focused baseline.
# Keep these modules available in platform/infrastructure/modules/ for later phases,
# but do not instantiate them while the environment is focused on SQL database
# infrastructure and Pulumi-managed database users/roles/grants.
#
# module "network" {}
# module "vnet_peering" {}
# module "vpn_vm" {}
# module "aks" {}
# module "monitoring" {}
# module "private_dns" {}
# module "private_endpoint" {}
# module "backup_vault" {}
# module "key_vault" {}
