variable "namespace" {
  description = "Kubernetes namespace for Bindplane"
  type        = string
  default     = "bindplane"
}

variable "chart_version" {
  description = "Version of the Bindplane Helm chart"
  type        = string
  default     = "1.26.6" # Latest version from @https://github.com/observIQ/bindplane-op-helm/releases
}

variable "admin_username" {
  description = "Admin username for Bindplane"
  type        = string
  default     = "admin"
}

// TODO(jsirianni): We should document the implications of
// plain text sensitive values. They are stored in plain text
// in the state backend. Backends might use encryption at rest
// but that might not be enough for most users.check"
// This applies for all sensitive fields, not just "admin_password"
variable "admin_password" {
  description = "Admin password for Bindplane"
  type        = string
  sensitive   = true
}

variable "sessions_secret" {
  description = "Random UUIDv4 used to derive web interface session tokens"
  type        = string
  sensitive   = true
}

variable "license_key" {
  description = "Your Bindplane license key"
  type        = string
  sensitive   = true
}

variable "values" {
  description = "Additional values to pass to the Helm chart"
  type        = map(any)
  default     = {}
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

variable "database_user" {
  description = "Database user for Bindplane"
  type        = string
}

variable "database_password" {
  description = "Database password for Bindplane"
  type        = string
  sensitive   = true
}

variable "chart_name" {
  description = "Name of the Helm chart"
  type        = string
  default     = "bindplane"
}

variable "repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = "https://observiq.github.io/bindplane-op-helm"
}

variable "secret_name" {
  description = "Name of the Kubernetes secret for Bindplane configuration"
  type        = string
  default     = "bindplane"
}
