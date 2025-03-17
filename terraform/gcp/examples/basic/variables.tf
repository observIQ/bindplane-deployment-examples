variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
  default     = "us-central1"
}

variable "network_name" {
  description = "The name of the network"
  type        = string
  default     = "bindplane-basic"
}

# Optional network configuration overrides
variable "subnet_ip_range" {
  description = "The IP range for the subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_ip_range" {
  description = "The IP range for GKE pods"
  type        = string
  default     = "10.1.0.0/16"
}

variable "services_ip_range" {
  description = "The IP range for GKE services"
  type        = string
  default     = "10.2.0.0/20"
}

# Add cluster name variable
variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "bindplane"
}

variable "database_password" {
  description = "Password for the database user"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment (development, staging, production)"
  type        = string
  default     = "development"
}

variable "admin_password" {
  description = "Password for the Bindplane admin user"
  type        = string
  sensitive   = true
}

variable "bindplane_license" {
  description = "License key for Bindplane"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "bindplane"
}

variable "machine_type" {
  description = "GKE node machine type"
  type        = string
  default     = "e2-standard-2"
}

variable "initial_nodes" {
  description = "Initial number of nodes in the GKE cluster"
  type        = number
  default     = 1
}

variable "min_nodes" {
  description = "Minimum number of nodes in the GKE cluster"
  type        = number
  default     = 1
}

variable "max_nodes" {
  description = "Maximum number of nodes in the GKE cluster"
  type        = number
  default     = 3
}

variable "disk_size_gb" {
  description = "Size of the disk in GB"
  type        = number
  default     = 10
}

variable "instance_tier" {
  description = "The tier for the CloudSQL instance"
  type        = string
  default     = "db-f1-micro"
}

variable "database_name" {
  description = "Name of the database"
  type        = string
  default     = "bindplane"
}

variable "database_user" {
  description = "Database username"
  type        = string
  default     = "bindplane"
}

variable "admin_username" {
  description = "Admin username for the application"
  type        = string
  default     = "admin"
}
