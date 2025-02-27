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

output "bindplane_pubsub_project_id" {
  description = "The project ID for the Pub/Sub topic used by BindPlane"
  value       = var.project_id
}

output "bindplane_pubsub_topic" {
  description = "The topic ID for the Pub/Sub topic used by BindPlane"
  value       = module.pubsub.topic_name
}

output "bindplane_iam_service_account_email" {
  description = "The email address of the IAM service account used by BindPlane"
  value       = google_service_account.bindplane.email
}

// Remote URL is comprised of the IP address used by the ingress resource
// defined in the readme. Agents will use this endpoint for all communication
// to Bindplane.
output "bindplane_remote_url" {
  description = "The remote URL for BindPlane"
  value       = "http://${google_compute_global_address.bindplane_ip.address}"
}
