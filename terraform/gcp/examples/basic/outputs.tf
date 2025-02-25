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
