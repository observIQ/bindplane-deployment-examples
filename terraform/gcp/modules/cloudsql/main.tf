# CloudSQL PostgreSQL instance
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

locals {
  instance_name = "${var.instance_name}-instance"
  backup_config = {
    enabled                        = var.backup_enabled
    start_time                     = var.backup_start_time
    point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
  }
}

# Cloud SQL instance
resource "google_sql_database_instance" "instance" {
  name             = local.instance_name
  database_version = "POSTGRES_16"
  region           = var.region
  project          = var.project_id

  settings {
    tier              = var.instance_tier
    availability_type = var.high_availability ? "REGIONAL" : "ZONAL"
    disk_size         = var.disk_size_gb
    disk_type         = var.disk_type
    disk_autoresize   = var.disk_autoresize

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = local.backup_config.enabled
      start_time                     = local.backup_config.start_time
      point_in_time_recovery_enabled = local.backup_config.point_in_time_recovery_enabled
      backup_retention_settings {
        retained_backups = var.backup_retention_days
      }
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 3
      update_track = "stable"
    }
  }

  deletion_protection = var.deletion_protection
}

# Database
resource "google_sql_database" "database" {
  name     = var.database_name
  instance = google_sql_database_instance.instance.name
  project  = var.project_id
}

# Database user
resource "google_sql_user" "user" {
  name     = var.database_user
  instance = google_sql_database_instance.instance.name
  password = var.database_password
  project  = var.project_id
}
