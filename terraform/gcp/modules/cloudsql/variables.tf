variable "project_id" {
  description = "The project ID to host the database in"
  type        = string
}

variable "region" {
  description = "The region to host the database in"
  type        = string
}

variable "network_id" {
  description = "The VPC network ID to host the database in"
  type        = string
}

variable "instance_name" {
  description = "The name of the database instance"
  type        = string
}

variable "database_name" {
  description = "The name of the database"
  type        = string
}

variable "database_user" {
  description = "The name of the database user"
  type        = string
}

variable "database_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
}

variable "instance_tier" {
  description = "The machine type to use"
  type        = string
}

variable "disk_size_gb" {
  description = "The size of data disk, in GB"
  type        = number
  default     = 250
}

variable "disk_type" {
  description = "The type of data disk"
  type        = string
  default     = "PD_SSD"
}

variable "backup_retention_days" {
  description = "The number of days to retain backups"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance"
  type        = bool
  default     = true
}

variable "high_availability" {
  description = "Enable high availability for the database instance"
  type        = bool
  default     = false
}

variable "disk_autoresize" {
  description = "Enable automatic disk resizing"
  type        = bool
  default     = true
}

<<<<<<< HEAD
variable "database_flags" {
  description = "Database flags for the CloudSQL instance"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "max_connections"
      value = "100"
    },
    {
      name  = "log_min_duration_statement"
      value = "300"
    }
  ]
}

variable "backup_start_time" {
  description = "Start time for the daily backup (in UTC)"
  type        = string
  default     = "02:00"
}

variable "backup_enabled" {
  description = "Whether backups are enabled"
  type        = bool
  default     = true
}

variable "point_in_time_recovery_enabled" {
  description = "Whether point-in-time recovery is enabled"
  type        = bool
  default     = true
=======
variable "max_connections" {
  description = "The maximum number of connections to the database"
  type        = number
  default     = 100
>>>>>>> c654be1 (configurable max connections)
}
