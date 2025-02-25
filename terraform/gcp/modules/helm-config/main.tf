# Let Helm create the namespace first
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
    name      = "bindplane"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
    annotations = {
      "meta.helm.sh/release-name"      = "bindplane"
      "meta.helm.sh/release-namespace" = var.namespace
    }
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

  name             = "bindplane"
  repository       = "https://observiq.github.io/bindplane-op-helm"
  chart            = "bindplane"
  version          = var.chart_version
  namespace        = var.namespace
  create_namespace = true

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
        }
      }

      # Use our created secret
      config = {
        secret           = kubernetes_secret.bindplane_config.metadata[0].name
        licenseUseSecret = true
        accept_eula      = true
      }

      transformAgent = {
        readinessProbe = {
          initialDelaySeconds = 5
          periodSeconds       = 10
        }
      }
    }, var.values))
  ]

  depends_on = [kubernetes_secret.bindplane_config]
}
