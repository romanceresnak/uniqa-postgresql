# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  name                = "psql-${var.project_name}-${var.environment}-${substr(var.location, 0, 3)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  version                      = var.postgresql_version
  administrator_login          = var.administrator_login
  administrator_password       = var.administrator_password
  zone                        = var.availability_zone
  storage_mb                  = var.storage_mb
  sku_name                    = var.sku_name
  backup_retention_days       = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled

  # High Availability configuration
  dynamic "high_availability" {
    for_each = var.high_availability_mode != null ? [1] : []
    content {
      mode                      = var.high_availability_mode
      standby_availability_zone = var.standby_availability_zone
    }
  }

  # Maintenance window
  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = merge(
    var.tags,
    {
      Module      = "postgresql"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}

# PostgreSQL Databases
resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each = var.databases

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main.id
  collation = lookup(each.value, "collation", "en_US.utf8")
  charset   = lookup(each.value, "charset", "UTF8")
}

# PostgreSQL Firewall Rules for Azure Services
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_azure_services" {
  count = var.allow_azure_services ? 1 : 0

  name             = "AllowAzureServices"
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# PostgreSQL Firewall Rules for specific IPs
resource "azurerm_postgresql_flexible_server_firewall_rule" "firewall_rules" {
  for_each = var.firewall_rules

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.main.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

# Private Endpoint for VNet integration
resource "azurerm_private_endpoint" "postgresql" {
  count = var.private_endpoint_subnet_id != null ? 1 : 0

  name                = "pe-${azurerm_postgresql_flexible_server.main.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "psc-${azurerm_postgresql_flexible_server.main.name}"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main.id
    is_manual_connection          = false
    subresource_names             = ["postgresqlServer"]
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id != null ? [1] : []
    content {
      name                 = "pdnszg-${azurerm_postgresql_flexible_server.main.name}"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = merge(
    var.tags,
    {
      Module = "postgresql"
    }
  )
}

# PostgreSQL Server Parameters
resource "azurerm_postgresql_flexible_server_configuration" "config" {
  for_each = var.postgresql_configurations

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main.id
  value     = each.value
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "postgresql" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "diag-${azurerm_postgresql_flexible_server.main.name}"
  target_resource_id         = azurerm_postgresql_flexible_server.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "PostgreSQLLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Alert Rules
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  count = var.enable_monitoring_alerts && var.action_group_id != null ? 1 : 0

  name                = "alert-cpu-${azurerm_postgresql_flexible_server.main.name}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_postgresql_flexible_server.main.id]
  description         = "Alert when CPU exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "cpu_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.cpu_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

resource "azurerm_monitor_metric_alert" "storage_alert" {
  count = var.enable_monitoring_alerts && var.action_group_id != null ? 1 : 0

  name                = "alert-storage-${azurerm_postgresql_flexible_server.main.name}"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_postgresql_flexible_server.main.id]
  description         = "Alert when storage usage exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"

  criteria {
    metric_namespace = "Microsoft.DBforPostgreSQL/flexibleServers"
    metric_name      = "storage_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.storage_alert_threshold
  }

  action {
    action_group_id = var.action_group_id
  }

  tags = var.tags
}

# Azure AD Authentication
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "main" {
  count = var.ad_admin_login != null ? 1 : 0

  server_name         = azurerm_postgresql_flexible_server.main.name
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  object_id           = var.ad_admin_object_id
  principal_name      = var.ad_admin_login
  principal_type      = "User"
}