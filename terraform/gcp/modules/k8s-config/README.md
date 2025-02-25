# Kubernetes Configuration Module

This module sets up the basic Kubernetes resources needed for Bindplane:

- Dedicated namespace
- Service account
- Database credentials secret

## Features

- Creates isolated namespace for Bindplane components
- Sets up service account for Bindplane workloads
- Manages database credentials securely in Kubernetes secrets
- Consistent environment labeling across resources

## Usage

```hcl
module "k8s_config" {
  source = "../../modules/k8s-config"

  providers = {
    kubernetes.gke = kubernetes.gke
  }

  namespace         = "bindplane"
  environment       = "production"
  database_user     = "bindplane"
  database_password = var.database_password
  database_host     = module.cloudsql.private_ip_address
  database_name     = "bindplane"
}
```

## Requirements

- Kubernetes provider configured with GKE cluster access
- Cloud SQL instance with database credentials
- GKE cluster with workload identity enabled

## Provider Configuration

This module requires a Kubernetes provider with alias "gke". Configure it in your root module:

```hcl
provider "kubernetes" {
  host                   = "https://${module.gke.cluster_endpoint}"
  cluster_ca_certificate = base64decode(module.gke.cluster_ca_certificate)
  token                  = data.google_client_config.current.access_token
  alias                  = "gke"
}
```

## Inputs

| Name              | Description                             | Type   | Default      | Required |
| ----------------- | --------------------------------------- | ------ | ------------ | :------: |
| namespace         | Kubernetes namespace for Bindplane      | string | "bindplane"  |    no    |
| environment       | Environment label to apply to resources | string | "production" |    no    |
| database_user     | Database user for Bindplane             | string | -            |   yes    |
| database_password | Database password for Bindplane         | string | -            |   yes    |
| database_host     | Database host for Bindplane             | string | -            |   yes    |
| database_name     | Database name for Bindplane             | string | "bindplane"  |    no    |

## Outputs

| Name                 | Description                                 |
| -------------------- | ------------------------------------------- |
| namespace            | The Kubernetes namespace                    |
| service_account_name | The name of the Kubernetes service account  |
| db_secret_name       | The name of the database credentials secret |

## Validation

After applying, verify the resources:

```bash
# Check namespace
kubectl get namespace bindplane

# Verify service account
kubectl get serviceaccount -n bindplane

# Check secret (don't decode in production)
kubectl get secret bindplane-db-credentials -n bindplane -o jsonpath='{.data}'
```
