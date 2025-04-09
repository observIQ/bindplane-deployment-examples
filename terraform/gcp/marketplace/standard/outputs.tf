output "endpoint" {
  description = "The external IP address of the instance formatted as a URL."
  value       = module.bindplane.endpoint
}

output "ssh_command" {
  description = "The gcloud command to SSH into the instance."
  value       = module.bindplane.ssh_command
}
