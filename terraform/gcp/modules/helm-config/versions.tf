terraform {
  required_providers {
    helm = {
      source                = "hashicorp/helm"
      version               = "~> 2.0"
      configuration_aliases = [helm.gke]
    }
    kubernetes = {
      source                = "hashicorp/kubernetes"
      version               = "~> 2.0"
      configuration_aliases = [kubernetes.gke]
    }
  }
}
