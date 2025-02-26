# Helm Configuration Module

This module installs and configures Bindplane using Helm.

## Features

- Installs Bindplane using the official Helm chart
- Uses official Helm repository at observiq.github.io/bindplane-op-helm
- Configures Postgres backend for production use
- Manages Bindplane admin credentials securely
- Sets up session management and licensing
- Configures EULA acceptance
- Configures transform agent with proper startup delays

## Usage

```hcl
module "helm_config" {
  source = "../../modules/helm-config"

  providers = {
    helm.gke       = helm.gke
    kubernetes.gke = kubernetes.gke
  }

  namespace         = "bindplane"
  admin_username    = "admin"
  admin_password    = var.admin_password
  sessions_secret   = random_uuid.bindplane_session.result
  license_key       = var.bindplane_license
  database_host     = module.cloudsql.private_ip_address
  database_name     = "bindplane"
  database_user     = "bindplane"
  database_password = var.database_password
}

resource "random_uuid" "bindplane_session" {}
```

## Requirements

- Kubernetes cluster with Helm v3
- PostgreSQL database
- Bindplane license key
- Kubernetes and Helm providers configured

## Provider Configuration

This module requires both Kubernetes and Helm providers with GKE aliases:

```hcl
provider "helm" {
  kubernetes {
    host                   = "https://${module.gke.cluster_endpoint}"
    cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
    token                  = data.google_client_config.current.access_token
  }
  alias = "gke"
}

provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
  alias                  = "gke"
}
```

## Inputs

| Name            | Description                                 | Type     | Default     | Required |
| --------------- | ------------------------------------------- | -------- | ----------- | :------: |
| namespace       | Kubernetes namespace for Bindplane          | string   | "binplane" |    no    |
| chart_version   | Version of the Bindplane Helm chart         | string   | "1.27.0"    |    no    |
| admin_username  | Admin username for Bindplane                | string   | "admin"     |    no    |
| admin_password  | Admin password for Bindplane                | string   | -           |   yes    |
| sessions_secret | Random UUIDv4 for session tokens            | string   | -           |   yes    |
| license_key     | Your Bindplane license key                  | string   | -           |   yes    |
| values          | Additional values to pass to the Helm chart | map(any) | {}          |    no    |

## Validation

After applying, verify the deployment:

```bash
# Check Helm release
helm list -n bindplane

# Check Bindplane pods
kubectl get pods -n bindplane

# Verify transform agent is ready
kubectl get pods -n bindplane -l app.kubernetes.io/component=transform-agent

# Verify Bindplane is running
kubectl port-forward svc/bindplane 3001:3001 -n bindplane
# Access http://localhost:3001 in your browser
# Login with admin/<admin_password>
```

## Components

The deployment includes:

- Main Bindplane server
- Transform agent (with readiness probe)
- Prometheus instance
- PostgreSQL backend connection
