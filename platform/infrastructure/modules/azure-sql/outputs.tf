output "server_id" {
  description = "Azure SQL server ID."
  value       = azurerm_mssql_server.this.id
}

output "server_name" {
  description = "Azure SQL server name."
  value       = azurerm_mssql_server.this.name
}

output "server_fully_qualified_domain_name" {
  description = "Azure SQL server FQDN."
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "elastic_pool_ids" {
  description = "Elastic pool IDs keyed by logical name."
  value       = { for key, pool in azurerm_mssql_elasticpool.this : key => pool.id }
}

output "database_ids" {
  description = "SQL database IDs keyed by logical name."
  value       = { for key, database in azurerm_mssql_database.this : key => database.id }
}

output "database_names" {
  description = "SQL database names keyed by logical name."
  value       = { for key, database in azurerm_mssql_database.this : key => database.name }
}
