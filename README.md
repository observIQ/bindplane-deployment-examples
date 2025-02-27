# Bindplane Deployment Examples

This repository provides deployment examples for Bindplane, a powerful observability pipeline management platform.
It includes multiple deployment options to suit different environments and requirements.

## Overview

Bindplane can be deployed in various environments, from simple Docker Compose
setups for development to production-ready GCP deployments with high availability
and security features. This repository contains examples for:

- Docker Compose deployment for local development and testing
- Terraform-based GCP deployment for production environments
- Kubernetes deployment using Helm charts

## Prerequisites

Depending on your chosen deployment method, you'll need:

### For All Deployments

- Bindplane license key (contact [Bindplane](https://bindplane.com/) for a trial)

### For Docker Compose

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### For GCP Terraform Deployment

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- A GCP project with billing enabled
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/) (v3.0.0+)

## Deployment Options

### 1. Docker Compose (Development)

The Docker Compose deployment is ideal for local development, testing, or small-scale deployments.

```bash
# Navigate to the Docker Compose directory
cd docker-compose

# Copy and edit the environment file
cp .env.example .env
# Edit .env with your license key and configuration

# Start Bindplane
docker-compose up -d
```

Access Bindplane at <http://localhost:3001>

### 2. GCP Terraform Deployment (Production)

The Terraform deployment creates a production-ready environment on Google Cloud Platform with:

- Private GKE cluster
- CloudSQL PostgreSQL with SSL encryption
- Secure networking and access controls
- High availability configuration

```bash
# Navigate to the Terraform example directory
cd terraform/gcp/examples/basic

# Copy and edit the variables file
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project ID, license key, etc.

# Initialize and apply Terraform
terraform init
terraform apply
```

After deployment, follow the instructions to access Bindplane through port forwarding or configure an ingress.

## Configuration

### Docker Compose Configuration

Edit the `.env` file to configure:

- Admin credentials
- Database settings
- License key
- Port mappings

### GCP Terraform Configuration

Key variables in `terraform.tfvars`:

| Variable            | Description               | Default             |
| ------------------- | ------------------------- | ------------------- |
| `project_id`        | Your GCP project ID       | (Required)          |
| `region`            | GCP region for resources  | `us-central1`       |
| `cluster_name`      | Name for the GKE cluster  | `bindplane-cluster` |
| `database_password` | Password for the database | (Required)          |
| `admin_username`    | Bindplane admin username  | `admin`             |
| `admin_password`    | Bindplane admin password  | (Required)          |
| `license_key`       | Bindplane license key     | (Required)          |
| `machine_type`      | GKE node machine type     | `e2-standard-2`     |
| `instance_tier`     | CloudSQL instance tier    | `db-f1-micro`       |

## Security Features

The GCP deployment includes several security enhancements:

- SSL/TLS encryption for database connections
- Network policies restricting pod communication
- Private GKE cluster with authorized networks
- Secure secrets management
- CloudSQL with private IP and SSL

## Scaling and High Availability

The GCP deployment supports:

- Node auto-scaling based on resource usage
- Regional GKE cluster for zone redundancy
- CloudSQL high availability option
- Persistent storage for metrics and logs

## Monitoring and Maintenance

### Health Checks

- Use Kubernetes liveness and readiness probes
- Monitor CloudSQL metrics in GCP console

### Backups

- CloudSQL automated backups
- Point-in-time recovery

## Troubleshooting

### Common Issues

- **Database Connection Issues**: Check CloudSQL instance status and network connectivity
- **Pod Startup Failures**: Use `kubectl logs` to view container logs
- **SSL Certificate Problems**: Verify certificates are properly mounted
- **Helm Timeout Errors**: If you encounter "context deadline exceeded" errors during deployment:

  ```bash
  # Check pod status
  kubectl get pods -n bindplane

  # Check pod details for errors
  kubectl describe pods -n bindplane

  # Check storage classes
  kubectl get storageclass

  # Verify SSL secrets
  kubectl get secret postgres-tls -n bindplane

  # Check resource allocation on nodes
  kubectl describe nodes | grep -A 5 "Allocated resources"

  # Check logs of failing pods
  kubectl logs -n bindplane <pod-name>

  # If SSL issues are suspected, try setting sslmode to disable in terraform.tfvars
  # or check that the SSL certificates are properly formatted
  ```

- **Resource Constraints**: If pods are failing to schedule due to insufficient resources:
  - Increase the size of your GKE node pool
  - Reduce CPU/memory requests in the Helm chart configuration
  - Scale down other workloads in the cluster

### Getting Help

- Check the [Bindplane documentation](https://docs.bindplane.com/bindplane)
- Contact [Bindplane Support](https://bindplane.com/support)

## Contributing

Contributions to these deployment examples are welcome! Please feel free to submit a Pull Request.

## Development Workflow

This project uses pre-commit hooks to ensure code quality and consistency.
Pre-commit automatically checks your code before each commit to catch
issues early.

For detailed information about the development workflow, including:

- Setting up pre-commit hooks
- Available hooks and what they check
- Coding standards and contribution guidelines
- Using conventional commits

Please refer to our [contribution guidelines](CONTRIBUTING.md).

## License

This project is licensed under the [Apache 2.0 License](LICENSE).

## Rollback and Recovery

If your deployment fails and you need to roll back:

```bash
# Delete the failed Helm release
helm delete bindplane -n bindplane

# Reapply with modified configuration
terraform apply
```

For persistent database issues:

```bash
# Connect to the CloudSQL instance
gcloud sql connect bindplane-instance --user=bindplane

# Check database status
\l
\c bindplane
\dt
```
