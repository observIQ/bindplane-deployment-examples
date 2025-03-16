variable "project_id" {
  description = "The project ID to host the cluster in"
  type        = string
}

variable "region" {
  description = "The region to host the cluster in"
  type        = string
}

variable "cluster_name" {
  description = "The name of the cluster"
  type        = string
}

variable "network_name" {
  description = "The VPC network to host the cluster in"
  type        = string
}

variable "subnet_name" {
  description = "The subnetwork to host the cluster in"
  type        = string
}

variable "pods_ip_range_name" {
  description = "The secondary ip range to use for pods"
  type        = string
}

variable "services_ip_range_name" {
  description = "The secondary ip range to use for services"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "The IP range in CIDR notation to use for the hosted master network"
  type        = string
  default     = "172.16.0.0/28"
}

variable "machine_type" {
  description = "The name of a Google Compute Engine machine type"
  type        = string
  default     = "e2-standard-4"
}

variable "initial_node_count" {
  description = "The initial number of nodes for the pool"
  type        = number
  default     = 3
}

variable "min_node_count" {
  description = "Minimum number of nodes in the NodePool per zone"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes in the NodePool per zone"
  type        = number
  default     = 5
}

variable "disk_size_gb" {
  description = "Size of the disk attached to each node"
  type        = number
  default     = 100
}

variable "environment" {
  description = "The environment this cluster will handle"
  type        = string
  default     = "production"
}

variable "node_service_account" {
  description = "The Google Cloud Platform Service Account to be used by the node VMs"
  type        = string
}

variable "additional_node_labels" {
  description = "Additional labels to add to the node pool"
  type        = map(string)
  default     = {}
}
