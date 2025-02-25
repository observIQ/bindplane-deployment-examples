# Basic Bindplane Deployment Example

This example demonstrates a basic deployment of Bindplane infrastructure on GCP.

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

## Tool Installation

### macOS

```bash
# Install Google Cloud SDK (if not already installed)
brew install google-cloud-sdk

# Install kubectl
brew install kubectl

# Install GKE auth plugin
gcloud components install gke-gcloud-auth-plugin
```

### Linux

Tools can be installed using the following documentation:

- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [Gcloud SDK](https://cloud.google.com/sdk/docs/install#linux)

Once Gcloud SDK is installed, install the GKE auth plugin:

```bash
gcloud components install gke-gcloud-auth-plugin
```

## Usage

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

## Components Created

- VPC network
- Subnet with secondary ranges for GKE
- Cloud NAT for outbound internet access
- Private Service Access for Cloud SQL
- Basic firewall rules:
  - Internal network communication
  - Health check access
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
- `bindplane_license`: Your Bindplane license key

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
