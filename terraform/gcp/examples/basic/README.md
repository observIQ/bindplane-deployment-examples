# Basic Bindplane Deployment Example

This example demonstrates a basic deployment of Bindplane infrastructure on GCP.

## Deployment Summary

This example deploys a basic Bindplane environment through the following operations:

1. Infrastructure Deployment (Terraform):
   - **Networking**: VPC network, subnets, Cloud NAT, private service access
   - **GKE Cluster**: Private cluster with autoscaling node pool
   - **Cloud SQL**: Private PostgreSQL instance for state storage
   - **IAM & Security**: Service account for GKE nodes
   - **Load Balancing**: Global IP address for ingress

2. Application Deployment (Kubernetes/Helm):
   - **Bindplane Server**: Single instance deployment
   - **Transform Agent**: Single instance for data processing
   - **Prometheus**: Single instance for agent throughput measurements
   - **Secrets Management**: Database credentials and license management

## Prerequisites

1. A GCP project with billing enabled
2. Required APIs enabled:
   - Compute Engine API (compute.googleapis.com)
   - Service Networking API (servicenetworking.googleapis.com)
   - Cloud Resource Manager API (cloudresourcemanager.googleapis.com)
   - Container API (container.googleapis.com)
   - Container Registry API (containerregistry.googleapis.com)
   - Cloud SQL Admin API (sqladmin.googleapis.com)
3. A GCS bucket for Terraform state (optional)
4. Local tools:
   - gcloud CLI
   - kubectl
   - google-cloud-sdk-gke-gcloud-auth-plugin

## Required GCP Permissions

The account used to apply this Terraform configuration needs the following IAM roles:

Project Level Roles:
  - `roles/compute.admin` - For managing compute resources, networks, and load balancers
  - `roles/container.admin` - For creating and managing GKE clusters
  - `roles/iam.serviceAccountAdmin` - For creating and managing service accounts
  - `roles/iam.serviceAccountUser` - For managing service account impersonation
  - `roles/cloudsql.admin` - For creating and managing Cloud SQL instances
  - `roles/servicenetworking.networksAdmin` - For configuring private service access
  - `roles/resourcemanager.projectIamAdmin` - For managing IAM policies
  - `roles/serviceusage.serviceUsageAdmin` - For enabling required APIs

Terraform will create an IAM Service Account with the following permissions:
   - GKE Node Service Account:
     - `roles/logging.logWriter`
     - `roles/monitoring.metricWriter`
     - `roles/monitoring.viewer`
     - `roles/stackdriver.resourceMetadata.writer`

## Tool Installation

### macOS

```bash
# Install Google Cloud SDK (if not already installed)
brew install google-cloud-sdk

# Install kubectl
brew install kubectl

# Install jq
brew install jq

# Install Helm
brew install helm

# Install GKE auth plugin
gcloud components install gke-gcloud-auth-plugin
```

### Linux

Tools can be installed using the following documentation:

- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [Gcloud SDK](https://cloud.google.com/sdk/docs/install#linux)
- [JQ](https://www.baeldung.com/linux/jq-command-json)
- [Helm](https://helm.sh/docs/helm/helm_install/)

Once Gcloud SDK is installed, install the GKE auth plugin:

```bash
gcloud components install gke-gcloud-auth-plugin
```

## Helm Setup

Add the Bindplane Helm repository:

```bash
helm repo add bindplane \
    https://observiq.github.io/bindplane-op-helm

helm repo update
```

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your project details:

```bash
cp terraform.tfvars.example terraform.tfvars
```

1. (Optional) Configure the Terraform backend:

```bash
# Copy the backend configuration example
cp backend.tf.example backend.tf

# Edit backend.tf and set your GCS bucket name
# This enables remote state storage and collaboration
```

1. Copy `terraform.tfvars.example` to `terraform.tfvars` and fill in your project details:

```bash
cp terraform.tfvars.example terraform.tfvars
```

2. (Optional) Configure the Terraform backend:

```bash
# Copy the backend configuration example
cp backend.tf.example backend.tf

# Edit backend.tf and set your GCS bucket name
# This enables remote state storage and collaboration
```

3. Initialize Terraform:

```bash
terraform init
```

4. Review the plan:

```bash
terraform plan -out bindplane.plan
```

5. Apply the configuration:

```bash
terraform apply bindplane.plan
```

6. Generate Helm values file:

```bash
./values.gen.sh
```

7. Connect to the GKE cluster:

```bash
terraform output -raw gcloud_command | bash
```

8. Create namespace and license secret:

Set `BINDPLANE_LICENSE` to your Bindplane license key and update
`your-secure-password` with a secure password. This will be the
password for the Bindplane admin user.

```bash
BINDPLANE_LICENSE="$(terraform output -raw bindplane_license)"

kubectl create namespace bindplane

kubectl create secret generic bindplane \
  --namespace bindplane \
  --from-literal=license=$BINDPLANE_LICENSE \
  --from-literal=username=admin \
  --from-literal=password=your-secure-password \
  --from-literal=sessions_secret=$(uuidgen)
```

9. Create database secret:

```bash
database_username=$(terraform output -raw database_username)
database_password=$(terraform output -raw database_password)

kubectl create secret generic bindplane-db \
  --namespace bindplane \
  --from-literal=username="${database_username}" \
  --from-literal=password="${database_password}"
```

10. Deploy Bindplane:

```bash
helm upgrade \
  --install bindplane \
  --namespace bindplane \
  bindplane/bindplane \
  --values values.yaml
```

### Ingress

If you want to expose Bindplane to the internet, you can use an Ingress resource.
Create the file `ingress.yaml` with the following content:

```bash
# ingress.yaml
---
apiVersion: cloud.google.com/v1
kind: BackendConfig
metadata:
  name: bindplane-backend-config
  namespace: bindplane
spec:
  timeoutSec: 3600
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bindplane-ingress
  namespace: bindplane
  annotations:
    kubernetes.io/ingress.class: "gce"
    # The IP bindplane-external-ip was created by terraform
    # in main.tf. Update if you changed the name variable.
    # "<name>-external-ip"
    kubernetes.io/ingress.global-static-ip-name: "bindplane-external-ip"
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: bindplane
            port:
              number: 3001
```

Apply the Ingress resource:

```bash
kubectl apply -f ingress.yaml
```

Wait for the Ingress to be ready:

```bash
kubectl get ingress -n bindplane
```

Once the Ingress is ready, you can access Bindplane at the IP address
associated with the Ingress.

Once the Ingress is ready, you can access Bindplane at the IP address
associated with the Ingress. It can take several minutes for the load
balancer to be provisioned.

> **_NOTE:_**  The [Bindplane Helm Chart](https://github.com/observIQ/bindplane-op-helm) supports
ingress directly when a hostname is provided. This example uses a static IP address.

## Components Created

- VPC network
- Subnet with secondary ranges for GKE
- Cloud NAT for outbound internet access
- Private Service Access for Cloud SQL
- Basic firewall rules:
  - Internal network communication
  - Health check access
- PubSub topic for Bindplane event bus
- GKE Cluster:
  - Private cluster configuration
  - Workload Identity enabled
  - Autoscaling node pool
  - Node service account with minimal permissions
  - Managed node labels including environment and app tags
- Cloud SQL:
  - Private PostgreSQL 15 instance
  - Automated backups enabled
  - Point-in-time recovery
  - VPC-native connectivity
- Kubernetes Resources:
  - Dedicated bindplane namespace
  - Service account for Bindplane workloads
  - Securely managed database credentials
  - Environment-specific labeling

## Accessing the Cluster

After deployment, you can access the cluster using:

```bash
# Configure kubectl
gcloud container clusters get-credentials bindplane-cluster \
    --region us-central1 \
    --project your-project-id

# Verify access
kubectl cluster-info
```

## Configuration

### Required Variables

- `project_id`: Your GCP project ID
- `database_password`: Password for the PostgreSQL user
- `admin_password`: Password for the Bindplane admin user
- `bindplane_license`: Your Bindplane Enterprise or Google license key

### Optional Variables

- `additional_node_labels`: Additional labels for GKE nodes
  [Previous variables remain unchanged...]

## Next Steps

After the infrastructure is set up, you can proceed with:

1. Accessing the Bindplane UI:

   ```bash
   kubectl port-forward svc/bindplane 3001:3001 -n bindplane
   # Visit http://localhost:3001
   # Login with:
   #   Username: admin
   #   Password: <value of admin_password>
   ```

2. Verify all components are running:

   ```bash
   # Check all pods
   kubectl get pods -n bindplane

   # Should show:
   # - bindplane-xxx (main server)
   # - bindplane-transform-agent-xxx
   # - bindplane-prometheus-0
   ```

3. Configure monitoring targets
4. Set up logging destinations

## Validation

### Testing Database Connectivity

```bash
# Create a test pod
kubectl run postgres-test --image=postgres:15 -- sleep infinity

# Wait for pod to be ready
kubectl wait --for=condition=ready pod/postgres-test

# Test database connection with the password from terraform.tfvars
kubectl exec postgres-test -- psql "host=10.129.0.2 dbname=bindplane user=bindplane password=your-secure-password"

# Clean up test pod when done
kubectl delete pod postgres-test
```

### Reset Database Password

If you need to reset the database password:

```bash
gcloud sql users set-password bindplane \
    --instance=bindplane-instance \
    --password=your-secure-password
```

Make sure to update terraform.tfvars with the new password to keep configurations in sync.

## Troubleshooting

### Unable to connect to GKE cluster

If you see an error about `gke-gcloud-auth-plugin not found`, install the auth plugin:

```bash
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin
```

Then reconfigure kubectl:

```bash
gcloud container clusters get-credentials bindplane-cluster \
    --region us-central1 \
    --project your-project-id
```
