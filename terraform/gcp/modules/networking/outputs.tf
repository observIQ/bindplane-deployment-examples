output "network_id" {
  description = "The ID of the VPC"
  value       = google_compute_network.vpc.id
}

output "network_name" {
  description = "The name of the VPC"
  value       = google_compute_network.vpc.name
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = google_compute_subnetwork.subnet.id
}

output "subnet_name" {
  description = "The name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "pods_ip_range_name" {
  description = "The name of the secondary IP range for pods"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[0].range_name
}

output "services_ip_range_name" {
  description = "The name of the secondary IP range for services"
  value       = google_compute_subnetwork.subnet.secondary_ip_range[1].range_name
} 
