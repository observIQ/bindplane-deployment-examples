output "namespace" {
  description = "The Kubernetes namespace"
  value       = kubernetes_namespace.bindplane.metadata[0].name
}

output "service_account_name" {
  description = "The name of the Kubernetes service account"
  value       = kubernetes_service_account.bindplane.metadata[0].name
}

output "db_secret_name" {
  description = "The name of the database credentials secret"
  value       = kubernetes_secret.db_creds.metadata[0].name
} 
