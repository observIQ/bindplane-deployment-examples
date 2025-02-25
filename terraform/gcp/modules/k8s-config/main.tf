# Create namespace for Bindplane
resource "kubernetes_namespace" "bindplane" {
  provider = kubernetes.gke
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
    }
  }
}

# Create service account for Bindplane
resource "kubernetes_service_account" "bindplane" {
  provider = kubernetes.gke
  metadata {
    name      = "bindplane"
    namespace = kubernetes_namespace.bindplane.metadata[0].name
    labels = {
      environment = var.environment
    }
  }
}

# Create database credentials secret
resource "kubernetes_secret" "db_creds" {
  provider = kubernetes.gke
  metadata {
    name      = "bindplane-db-credentials"
    namespace = kubernetes_namespace.bindplane.metadata[0].name
    labels = {
      environment = var.environment
    }
  }

  data = {
    username = var.database_user
    password = var.database_password
    host     = var.database_host
    dbname   = var.database_name
  }
}
