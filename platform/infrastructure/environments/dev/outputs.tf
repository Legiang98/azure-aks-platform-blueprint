output "resource_group_name" {
  description = "SQL baseline resource group name."
  value       = module.resource_group[local.primary_resource_group_key].name
}

output "azure_sql_server_name" {
  description = "Azure SQL logical server name."
  value       = module.azure_sql[local.primary_sql_server_key].server_name
}

output "azure_sql_server_fqdn" {
  description = "Azure SQL logical server FQDN."
  value       = module.azure_sql[local.primary_sql_server_key].server_fully_qualified_domain_name
}

output "azure_sql_elastic_pool_ids" {
  description = "Azure SQL elastic pool IDs keyed by logical name."
  value       = module.azure_sql[local.primary_sql_server_key].elastic_pool_ids
}

output "azure_sql_database_names" {
  description = "Azure SQL database names keyed by logical name."
  value       = module.azure_sql[local.primary_sql_server_key].database_names
}

output "managed_identity_client_ids" {
  description = "User-assigned managed identity client IDs keyed by logical name."
  value       = { for key, identity in module.managed_identity : key => identity.client_id }
}

output "managed_identity_principal_ids" {
  description = "User-assigned managed identity principal IDs keyed by logical name. Use these as Pulumi app01AzureSql user objectId values."
  value       = { for key, identity in module.managed_identity : key => identity.principal_id }
}

output "github_actions_client_id" {
  description = "Client ID of the GitHub Actions managed identity used by azure/login OIDC."
  value       = try(module.managed_identity["github_actions"].client_id, null)
}

output "container_registry_login_servers" {
  description = "Azure Container Registry login servers keyed by logical name."
  value       = { for key, registry in module.container_registry : key => registry.login_server }
}

output "container_registry_names" {
  description = "Azure Container Registry names keyed by logical name."
  value       = { for key, registry in module.container_registry : key => registry.name }
}
