output "server_id" {
  description = "The ID of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.id
}

output "server_name" {
  description = "The name of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.name
}

output "server_fqdn" {
  description = "The FQDN of the PostgreSQL server"
  value       = azurerm_postgresql_flexible_server.main.fqdn
}

output "administrator_login" {
  description = "The administrator login"
  value       = var.administrator_login
}

output "database_ids" {
  description = "Map of database names to their IDs"
  value       = { for k, v in azurerm_postgresql_flexible_server_database.databases : k => v.id }
}

output "database_names" {
  description = "List of created database names"
  value       = keys(azurerm_postgresql_flexible_server_database.databases)
}

output "connection_string" {
  description = "PostgreSQL connection string (without password)"
  value       = "postgresql://${var.administrator_login}@${azurerm_postgresql_flexible_server.main.fqdn}:5432/postgres?sslmode=require"
}

output "jdbc_url" {
  description = "JDBC URL for PostgreSQL"
  value       = "jdbc:postgresql://${azurerm_postgresql_flexible_server.main.fqdn}:5432/postgres?sslmode=require"
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = var.private_endpoint_subnet_id != null ? azurerm_private_endpoint.postgresql[0].id : null
}

output "private_endpoint_ip" {
  description = "The private IP address of the private endpoint"
  value       = var.private_endpoint_subnet_id != null && length(azurerm_private_endpoint.postgresql) > 0 ? azurerm_private_endpoint.postgresql[0].private_service_connection[0].private_ip_address : null
}

output "identity_principal_id" {
  description = "The principal ID of the managed identity"
  value       = azurerm_postgresql_flexible_server.main.identity[0].principal_id
}

output "identity_tenant_id" {
  description = "The tenant ID of the managed identity"
  value       = azurerm_postgresql_flexible_server.main.identity[0].tenant_id
}

output "server_configuration" {
  description = "Current server configuration"
  value = {
    version                      = azurerm_postgresql_flexible_server.main.version
    sku_name                     = azurerm_postgresql_flexible_server.main.sku_name
    storage_mb                   = azurerm_postgresql_flexible_server.main.storage_mb
    backup_retention_days        = azurerm_postgresql_flexible_server.main.backup_retention_days
    geo_redundant_backup_enabled = azurerm_postgresql_flexible_server.main.geo_redundant_backup_enabled
    zone                        = azurerm_postgresql_flexible_server.main.zone
  }
}

output "high_availability_status" {
  description = "High availability configuration status"
  value = var.high_availability_mode != null ? {
    enabled                   = true
    mode                     = var.high_availability_mode
    standby_availability_zone = var.standby_availability_zone
  } : {
    enabled = false
  }
}