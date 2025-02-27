variable "namespace" {
  description = "Kubernetes namespace for Bindplane"
  type        = string
  default     = "bindplane"
}

variable "environment" {
  description = "Environment label to apply to resources"
  type        = string
  default     = "production"
}

variable "database_user" {
  description = "Database user for Bindplane"
  type        = string
}

variable "database_password" {
  description = "Database password for Bindplane"
  type        = string
  sensitive   = true
}

variable "database_host" {
  description = "The hostname or IP address of the database"
  type        = string
}

variable "database_name" {
  description = "Database name for Bindplane"
  type        = string
  default     = "bindplane"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account"
  type        = string
  default     = "bindplane"
}

variable "secret_name" {
  description = "Name of the Kubernetes secret for database credentials"
  type        = string
  default     = "bindplane-db-credentials"
}
