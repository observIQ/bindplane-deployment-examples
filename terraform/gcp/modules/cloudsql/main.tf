# CloudSQL PostgreSQL instance
locals {
  instance_name = "${var.instance_name}-instance"
  database_flags = [
    {
      name  = "max_connections"
      value = "100"
    },
    {
      name  = "log_min_duration_statement"
      value = "300"
    }
  ]
  backup_config = {
    enabled                        = true
    start_time                     = "02:00"
    point_in_time_recovery_enabled = true
  }
}

# Cloud SQL instance
resource "google_sql_database_instance" "instance" {
  name             = local.instance_name
  database_version = "POSTGRES_15"
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
      require_ssl                                   = false
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
      for_each = local.database_flags
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
