# Let Helm create the namespace first
locals {
  labels = {
    "app.kubernetes.io/managed-by" = "Helm"
  }
  annotations = {
    "meta.helm.sh/release-name"      = var.chart_name
    "meta.helm.sh/release-namespace" = var.namespace
  }
}

resource "kubernetes_namespace" "bindplane" {
  provider = kubernetes.gke
  metadata {
    name = var.namespace
  }
}

# Create secret for Bindplane configuration
resource "kubernetes_secret" "bindplane_config" {
  provider   = kubernetes.gke
  depends_on = [kubernetes_namespace.bindplane]

  metadata {
    name        = var.secret_name
    namespace   = var.namespace
    labels      = local.labels
    annotations = local.annotations
  }

  data = {
    username        = var.admin_username
    password        = var.admin_password
    sessions_secret = var.sessions_secret
    license         = var.license_key
  }
}

resource "helm_release" "bindplane" {
  provider = helm.gke

  name             = var.chart_name
  repository       = var.repository
  chart            = var.chart_name
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true
  timeout          = 900 # Increase timeout to 15 minutes (from default 5 minutes)

  values = [
    yamlencode(merge({
      # Configure Postgres backend
      backend = {
        type = "postgres"
        postgres = {
          host     = var.database_host
          port     = 5432
          database = var.database_name
          username = var.database_user
          password = var.database_password
          sslmode  = "disable"
        }
      }

      # Use our created secret
      config = {
        secret           = var.secret_name
        licenseUseSecret = true
        accept_eula      = true
      }

      transformAgent = {
        readinessProbe = {
          initialDelaySeconds = 5
          periodSeconds       = 10
        }
        resources = {
          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
          requests = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }

      # Add resource limits for server
      server = {
        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      # Add resource limits for Prometheus
      prometheus = {
        resources = {
          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "200m"
            memory = "512Mi"
          }
        }
        # Add persistence configuration
        persistence = {
          enabled      = true
          storageClass = "standard"
          size         = "10Gi"
          accessMode   = "ReadWriteOnce"
          annotations = {
            "helm.sh/resource-policy" = "keep"
          }
        }
      }
    }, var.values))
  ]

  depends_on = [kubernetes_secret.bindplane_config]
}
