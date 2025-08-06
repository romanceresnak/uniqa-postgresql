# Azure PostgreSQL Flexible Server Terraform Module

This module creates an Azure PostgreSQL Flexible Server with support for high availability, private endpoints, monitoring, and comprehensive security features.

## Features

- PostgreSQL Flexible Server with configurable version (11-16)  
- Support for multiple databases with custom collation and charset  
- High Availability configuration (Zone Redundant or Same Zone)  
- Private endpoint for secure VNet integration  
- Firewall rules management for IP whitelisting  
- Azure AD authentication support  
- Automated backups with configurable retention (7-35 days)  
- Geo-redundant backup option  
- Diagnostic settings with Log Analytics integration  
- CPU and storage monitoring alerts  
- Custom server parameter configurations  
- Configurable maintenance window  
- System-assigned managed identity  

## Usage

### Basic Example

```hcl
module "postgresql" {
  source = "git::https://gitlab.com/your-org/terraform-module-azure-postgresql.git?ref=v1.0.0"

  resource_group_name = azurerm_resource_group.main.name
  location           = "westeurope"
  environment        = "prod"
  project_name       = "myapp"
  
  # Server configuration
  postgresql_version     = "14"
  administrator_login    = "psqladmin"
  administrator_password = var.db_admin_password
  sku_name              = "GP_Standard_D4s_v3"
  storage_mb            = 65536  # 64GB
  
  # Databases
  databases = {
    app_db = {
      collation = "en_US.utf8"
      charset   = "UTF8"
    }
  }
  
  # Networking
  private_endpoint_subnet_id = module.networking.subnet_ids["database"]
  private_dns_zone_id       = module.networking.private_dns_zone_postgres_id
  
  tags = {
    Project    = "MyApplication"
    CostCenter = "IT"
  }
}
```

## Requirements
Name	Version
terraform	>= 1.0

azurerm	>= 3.0, < 4.0

## Providers
Name	Version

azurerm	>= 3.0, < 4.0

### Inputs
| Name | Description | Type | Default | Required |
| ----------------------------------------- | -------------------------------------------- | -------------- | ------- | -------- |
| resource\_group\_name | The name of the resource group | `string` | n/a | ✅ |
| location | Azure region for resources | `string` | n/a | ✅ |
| environment | Environment name (dev, staging, prod) | `string` | n/a | ✅ |
| project\_name | Project name for resource naming | `string` | n/a | ✅ |
| administrator\_password | Administrator password for PostgreSQL server | `string` | n/a | ✅ |
| postgresql\_version | PostgreSQL server version | `string` | `"14"` | ❌ |
| administrator\_login | Administrator login for PostgreSQL server | `string` | `"psqladmin"` | ❌ |
| sku\_name | SKU name for the PostgreSQL server | `string` | `"GP_Standard_D2s_v3"` | ❌ |
| storage\_mb | Storage size in MB | `number` | `32768` | ❌ |
| backup\_retention\_days | Backup retention days (7-35) | `number` | `7` | ❌ |
| geo\_redundant\_backup\_enabled | Enable geo-redundant backups | `bool` | `false` | ❌ |
| availability\_zone | Availability zone for the primary server | `string` | `"1"` | ❌ |
| high\_availability\_mode | High availability mode (ZoneRedundant or SameZone) | `string` | `null` | ❌ |
| standby\_availability\_zone | Availability zone for the standby server | `string` | `"2"` | ❌ |
| databases | Map of databases to create | `map(object)` | `{}` | ❌ |
| allow\_azure\_services | Allow access from Azure services | `bool` | `false` | ❌ |
| firewall\_rules | Map of firewall rules | `map(object)` | `{}` | ❌ |
| private\_endpoint\_subnet\_id | Subnet ID for private endpoint | `string` | `null` | ❌ |
| private\_dns\_zone\_id | Private DNS zone ID for private endpoint | `string` | `null` | ❌ |
| postgresql\_configurations | PostgreSQL server configurations | `map(string)` | `{}` | ❌ |
| maintenance\_window | Maintenance window configuration | `object` | `null` | ❌ |
| log\_analytics\_workspace\_id | Log Analytics workspace ID for diagnostics | `string` | `null` | ❌ |
| enable\_monitoring\_alerts | Enable monitoring alerts | `bool` | `true` | ❌ |
| cpu\_alert\_threshold | CPU percentage threshold for alerts | `number` | `80` | ❌ |
| storage\_alert\_threshold | Storage percentage threshold for alerts | `number` | `80` | ❌ |
| action\_group\_id | Action group ID for alerts | `string` | `null` | ❌ |
| tenant\_id | Azure AD tenant ID | `string` | `null` | ❌ |
| ad\_admin\_login | Azure AD admin login name | `string` | `null` | ❌ |
| ad\_admin\_object\_id | Azure AD admin object ID | `string` | `null` | ❌ |
| tags | Common tags to apply to all resources | `map(string)` | `{}` | ❌ |

### Outputs
| Name | Description |
| --------------------------------------- | ------------------------------------------------- |
| server\_id | The ID of the PostgreSQL server |
| server\_name | The name of the PostgreSQL server |
| server\_fqdn | The FQDN of the PostgreSQL server |
| administrator\_login | The administrator login |
| database\_ids | Map of database names to their IDs |
| database\_names | List of created database names |
| connection\_string | PostgreSQL connection string (without password) |
| jdbc\_url | JDBC URL for PostgreSQL |
| private\_endpoint\_id | The ID of the private endpoint |
| private\_endpoint\_ip | The private IP address of the private endpoint |
| identity\_principal\_id | The principal ID of the managed identity |
| identity\_tenant\_id | The tenant ID of the managed identity |
| server\_configuration | Current server configuration |
| high\_availability\_status | High availability configuration status |

### SKU Options
| SKU Name | vCores | Memory | Max Storage | Use Case |
|----------|--------|--------|-------------|----------|
| B\_Standard\_B1ms | 1 | 2 GB | 16 TB | Dev/Test |
| B\_Standard\_B2s | 2 | 4 GB | 16 TB | Dev/Test |
| GP\_Standard\_D2s\_v3 | 2 | 8 GB | 16 TB | Small Production |
| GP\_Standard\_D4s\_v3 | 4 | 16 GB | 16 TB | Medium Production |
| GP\_Standard\_D8s\_v3 | 8 | 32 GB | 16 TB | Large Production |
| GP\_Standard\_D16s\_v3 | 16 | 64 GB | 16 TB | Enterprise |
| GP\_Standard\_D32s\_v3 | 32 | 128 GB | 16 TB | Enterprise |

### Security Considerations
- Always use private endpoints for production environments
- Enable Azure AD authentication for enhanced security
- Configure firewall rules restrictively
- Enable geo-redundant backups for critical data
- Use managed identity for Azure service authentication
- Regular security patching via maintenance windows
- Enable diagnostic logging for audit trails

### Resource Naming Convention
All resources follow Azure naming best practices:
- PostgreSQL Server: psql-{project_name}-{environment}-{location_short}
- Private Endpoint: pe-psql-{project_name}-{environment}-{location_short}
- Databases: User-defined names

### Cost Optimization
- Use B-series SKUs for development environments
- Right-size storage to avoid over-provisioning
- Disable geo-redundant backups in non-critical environments
- Consider reserved instances for production workloads
- Monitor and optimize based on actual usage patterns