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
  description = "Database host for Bindplane"
  type        = string
}

variable "database_name" {
  description = "Database name for Bindplane"
  type        = string
  default     = "bindplane"
} 
