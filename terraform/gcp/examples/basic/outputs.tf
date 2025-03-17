output "network_name" {
  description = "The name of the VPC network"
  value       = module.networking.network_name
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = module.networking.subnet_name
}

output "pods_ip_range_name" {
  description = "The name of the secondary IP range for pods"
  value       = module.networking.pods_ip_range_name
}

output "services_ip_range_name" {
  description = "The name of the secondary IP range for services"
  value       = module.networking.services_ip_range_name
}

output "database_host" {
  description = "The host of the database"
  value       = module.cloudsql.database_host
}

output "database_name" {
  description = "The name of the database"
  value       = module.cloudsql.database_name
}

output "database_username" {
  description = "The user of the database"
  value       = module.cloudsql.database_user
}

output "database_password" {
  description = "The password of the database"
  value       = var.database_password
  sensitive   = true
}

output "gcloud_command" {
  description = "The command to connect to the database"
  value       = "gcloud container clusters get-credentials ${module.gke.cluster_name} --region ${var.region} --project ${var.project_id}"
}

// Remote URL is comprised of the IP address used by the ingress resource
// defined in the readme. Agents will use this endpoint for all communication
// to Bindplane.
output "bindplane_remote_url" {
  description = "The remote URL for BindPlane"
  value       = "http://${google_compute_global_address.bindplane_ip.address}"
}

output "bindplane_license" {
  description = "The license key for BindPlane"
  value       = var.bindplane_license
}
