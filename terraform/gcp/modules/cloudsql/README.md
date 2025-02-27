# Cloud SQL Module

This module creates a private PostgreSQL instance in Cloud SQL with automated backups.

## Features

- Private PostgreSQL 15 instance
- VPC-native connectivity
- Automated backups with point-in-time recovery
- Configurable machine type and storage
- Regional availability (optional)

## Usage

```hcl
module "cloudsql" {
  source = "../../modules/cloudsql"

  project_id        = "your-project"
  region           = "us-central1"
  network_id       = "your-vpc-id"
  instance_name    = "your-instance"
  database_name    = "your-database"
  database_user    = "your-user"
  database_password = "your-password"

  # Optional configurations
  instance_tier    = "db-f1-micro"
  disk_size_gb     = 10
  availability_type = "REGIONAL"
}
```

## Requirements

- A VPC network with private service access configured
- Cloud SQL Admin API enabled
- Required IAM permissions:
  - cloudsql.instances.create
  - cloudsql.instances.update
  - cloudsql.databases.create
  - cloudsql.users.create

## Inputs

| Name                  | Description                                               | Type   | Default       | Required |
| --------------------- | --------------------------------------------------------- | ------ | ------------- | :------: |
| project_id            | The project ID to host the database in                    | string | -             |   yes    |
| region                | The region to host the database in                        | string | -             |   yes    |
| network_id            | The VPC network ID to host the database in                | string | -             |   yes    |
| instance_name         | The name of the database instance                         | string | -             |   yes    |
| database_name         | The name of the database                                  | string | -             |   yes    |
| database_user         | The name of the database user                             | string | -             |   yes    |
| database_password     | The password for the database user                        | string | -             |   yes    |
| instance_tier         | The machine type to use                                   | string | "db-f1-micro" |    no    |
| availability_type     | The availability type for the master instance             | string | "REGIONAL"    |    no    |
| disk_size_gb          | The size of data disk, in GB                              | number | 10            |    no    |
| disk_type             | The type of data disk                                     | string | "PD_SSD"      |    no    |
| backup_retention_days | The number of days to retain backups                      | number | 7             |    no    |
| deletion_protection   | Whether or not to allow Terraform to destroy the instance | bool   | true          |    no    |
