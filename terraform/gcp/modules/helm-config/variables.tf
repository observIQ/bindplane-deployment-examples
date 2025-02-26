variable "namespace" {
  description = "Kubernetes namespace for Bindplane"
  type        = string
  default     = "bindplane"
}

variable "chart_version" {
  description = "Version of the Bindplane Helm chart"
  type        = string
  default     = "1.27.0" # Latest version from @https://github.com/observIQ/bindplane-op-helm/releases
}

variable "admin_username" {
  description = "Admin username for Bindplane"
  type        = string
  default     = "admin"
}

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

variable "eventbus_type" {
  description = "Type of event bus to use. One of 'pubsub' or 'nats'"
  type        = string
  default     = ""
}

variable "pubsub_project_id" {
  description = "The project ID to host the PubSub topic"
  type        = string
  default     = ""
}

variable "pubsub_topic_name" {
  description = "Name of the PubSub topic to use for the event bus"
  type        = string
  default     = ""
}

variable "wif_service_account_email" {
  description = "Service account email for Workload Identity Federation, required when using PubSub event bus"
  type        = string
  default     = ""
}

variable "database_max_connections" {
  description = "Maximum number of connections to the database"
  type        = number
  default     = 80 // Less than the default Cloudsql limit of 100
}

variable "bindplane_replicas" {
  description = "Number of Bindplane replicas, should be 1 unless using a distributed event bus"
  type        = number
  default     = 1
}

variable "transform_agent_replicas" {
  description = "Number of Transform Agent replicas"
  type        = number
  default     = 1
}
