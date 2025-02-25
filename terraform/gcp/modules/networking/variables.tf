variable "project_id" {
  description = "The project ID to deploy to"
  type        = string
}

variable "region" {
  description = "The region to deploy to"
  type        = string
}

variable "network_name" {
  description = "The name of the network"
  type        = string
  default     = "bindplane"
}

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
