# Add terraform block at the top
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

# Create namespace for Bindplane
locals {
  secret_labels = {
    environment = var.environment
  }
}

# Use data source to reference existing namespace
data "kubernetes_namespace" "bindplane" {
  metadata {
    name = var.namespace
  }
}

# Use data source to reference existing service account
data "kubernetes_service_account" "bindplane" {
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
  }
}

# Create database credentials secret
resource "kubernetes_secret" "db_creds" {
  metadata {
    name      = var.secret_name
    namespace = var.namespace
    labels    = local.secret_labels
  }

  data = {
    username = var.database_user
    password = var.database_password
    host     = var.database_host
    dbname   = var.database_name
  }
  depends_on = [data.kubernetes_namespace.bindplane]
}

resource "kubernetes_manifest" "default_deny_policy" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "NetworkPolicy"
    metadata = {
      name      = "default-deny-all"
      namespace = var.namespace
    }
    spec = {
      podSelector = {}
      policyTypes = ["Ingress", "Egress"]
    }
  }

  depends_on = [data.kubernetes_namespace.bindplane]
}

resource "kubernetes_manifest" "allow_internal_policy" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "NetworkPolicy"
    metadata = {
      name      = "allow-bindplane-internal"
      namespace = var.namespace
    }
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/instance" = "bindplane"
        }
      }
      policyTypes = ["Ingress", "Egress"]
      ingress = [{
        from = [{
          podSelector = {
            matchLabels = {
              "app.kubernetes.io/instance" = "bindplane"
            }
          }
        }]
      }]
      egress = [
        {
          to = [{
            podSelector = {
              matchLabels = {
                "app.kubernetes.io/instance" = "bindplane"
              }
            }
          }]
        },
        {
          to = [{
            ipBlock = {
              cidr   = "0.0.0.0/0"
              except = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
            }
          }]
        }
      ]
    }
  }

  depends_on = [data.kubernetes_namespace.bindplane]
}

resource "kubernetes_manifest" "allow_db_policy" {
  manifest = {
    apiVersion = "networking.k8s.io/v1"
    kind       = "NetworkPolicy"
    metadata = {
      name      = "allow-bindplane-db"
      namespace = var.namespace
    }
    spec = {
      podSelector = {
        matchLabels = {
          "app.kubernetes.io/component" = "server"
        }
      }
      policyTypes = ["Egress"]
      egress = [{
        to = [{
          ipBlock = {
            cidr = "${var.database_host}/32"
          }
        }]
        ports = [{
          protocol = "TCP"
          port     = 5432
        }]
      }]
    }
  }

  depends_on = [data.kubernetes_namespace.bindplane]
}
