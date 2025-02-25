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
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "The availability type for the master instance"
  type        = string
  default     = "REGIONAL"
}

variable "disk_size_gb" {
  description = "The size of data disk, in GB"
  type        = number
  default     = 10
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
