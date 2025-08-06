variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "postgresql_version" {
  description = "PostgreSQL server version"
  type        = string
  default     = "14"
  validation {
    condition     = contains(["11", "12", "13", "14", "15", "16"], var.postgresql_version)
    error_message = "PostgreSQL version must be 11, 12, 13, 14, 15, or 16."
  }
}

variable "administrator_login" {
  description = "Administrator login for PostgreSQL server"
  type        = string
  default     = "psqladmin"
}

variable "administrator_password" {
  description = "Administrator password for PostgreSQL server"
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.administrator_password) >= 8
    error_message = "Administrator password must be at least 8 characters long."
  }
}

variable "sku_name" {
  description = "SKU name for the PostgreSQL server"
  type        = string
  default     = "GP_Standard_D2s_v3"
}

variable "storage_mb" {
  description = "Storage size in MB"
  type        = number
  default     = 32768
  validation {
    condition     = var.storage_mb >= 32768 && var.storage_mb <= 16777216
    error_message = "Storage must be between 32GB (32768 MB) and 16TB (16777216 MB)."
  }
}

variable "backup_retention_days" {
  description = "Backup retention days (7-35)"
  type        = number
  default     = 7
  validation {
    condition     = var.backup_retention_days >= 7 && var.backup_retention_days <= 35
    error_message = "Backup retention must be between 7 and 35 days."
  }
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for the primary server"
  type        = string
  default     = "1"
}

variable "high_availability_mode" {
  description = "High availability mode (ZoneRedundant or SameZone)"
  type        = string
  default     = null
  validation {
    condition     = var.high_availability_mode == null || contains(["ZoneRedundant", "SameZone"], var.high_availability_mode)
    error_message = "High availability mode must be ZoneRedundant or SameZone."
  }
}

variable "standby_availability_zone" {
  description = "Availability zone for the standby server"
  type        = string
  default     = "2"
}

variable "databases" {
  description = "Map of databases to create"
  type = map(object({
    collation = optional(string)
    charset   = optional(string)
  }))
  default = {}
}

variable "allow_azure_services" {
  description = "Allow access from Azure services"
  type        = bool
  default     = false
}

variable "firewall_rules" {
  description = "Map of firewall rules"
  type = map(object({
    start_ip = string
    end_ip   = string
  }))
  default = {}
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for private endpoint"
  type        = string
  default     = null
}

variable "postgresql_configurations" {
  description = "PostgreSQL server configurations"
  type        = map(string)
  default     = {}
}

variable "maintenance_window" {
  description = "Maintenance window configuration"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "enable_monitoring_alerts" {
  description = "Enable monitoring alerts"
  type        = bool
  default     = true
}

variable "cpu_alert_threshold" {
  description = "CPU percentage threshold for alerts"
  type        = number
  default     = 80
  validation {
    condition     = var.cpu_alert_threshold > 0 && var.cpu_alert_threshold <= 100
    error_message = "CPU alert threshold must be between 1 and 100."
  }
}

variable "storage_alert_threshold" {
  description = "Storage percentage threshold for alerts"
  type        = number
  default     = 80
  validation {
    condition     = var.storage_alert_threshold > 0 && var.storage_alert_threshold <= 100
    error_message = "Storage alert threshold must be between 1 and 100."
  }
}

variable "action_group_id" {
  description = "Action group ID for alerts"
  type        = string
  default     = null
}

variable "tenant_id" {
  description = "Azure AD tenant ID"
  type        = string
  default     = null
}

variable "ad_admin_login" {
  description = "Azure AD admin login name"
  type        = string
  default     = null
}

variable "ad_admin_object_id" {
  description = "Azure AD admin object ID"
  type        = string
  default     = null
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}