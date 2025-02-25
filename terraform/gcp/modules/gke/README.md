# GKE Module

This module creates a private GKE cluster with a separately managed node pool.

## Features

- Private GKE cluster
- Custom VPC and subnet configuration
- Workload Identity enabled
- Configurable node pool with autoscaling
- Managed node labels
- Private nodes with public control plane

## Usage

```hcl
module "gke" {
  source = "../../modules/gke"

  project_id             = "your-project"
  region                = "us-central1"
  cluster_name          = "your-cluster"
  network_name          = "your-vpc"
  subnet_name           = "your-subnet"
  pods_ip_range_name    = "pods"
  services_ip_range_name = "services"
  node_service_account  = "service-account@project.iam.gserviceaccount.com"

  # Optional configurations
  machine_type         = "e2-standard-2"
  initial_node_count   = 1
  min_node_count       = 1
  max_node_count       = 3
  environment          = "development"
  additional_node_labels = {
    "app" = "your-app"
  }
}
```

## Node Labels

The module manages node labels in the following way:

- Environment label is automatically added based on the environment variable
- GKE system labels are explicitly managed
- Additional custom labels can be added via the additional_node_labels variable

## Requirements

- A VPC network with secondary IP ranges
- Service account for nodes with appropriate IAM roles
- Required GCP APIs enabled

## Inputs

| Name                   | Description                                      | Type        | Default         | Required |
| ---------------------- | ------------------------------------------------ | ----------- | --------------- | :------: |
| project_id             | The project ID to host the cluster in            | string      | -               |   yes    |
| region                 | The region to host the cluster in                | string      | -               |   yes    |
| cluster_name           | The name of the cluster                          | string      | -               |   yes    |
| network_name           | The VPC network to host the cluster in           | string      | -               |   yes    |
| subnet_name            | The subnetwork to host the cluster in            | string      | -               |   yes    |
| pods_ip_range_name     | The secondary ip range to use for pods           | string      | -               |   yes    |
| services_ip_range_name | The secondary ip range to use for services       | string      | -               |   yes    |
| node_service_account   | The GCP Service Account to be used by nodes      | string      | -               |   yes    |
| machine_type           | The name of a Google Compute Engine machine type | string      | "e2-standard-4" |    no    |
| initial_node_count     | The initial number of nodes for the pool         | number      | 3               |    no    |
| min_node_count         | Minimum number of nodes in the NodePool          | number      | 3               |    no    |
| max_node_count         | Maximum number of nodes in the NodePool          | number      | 5               |    no    |
| disk_size_gb           | Size of the disk attached to each node           | number      | 100             |    no    |
| environment            | The environment this cluster will handle         | string      | "production"    |    no    |
| additional_node_labels | Additional labels to add to the node pool        | map(string) | {}              |    no    |
| master_ipv4_cidr_block | The IP range for the hosted master network       | string      | "172.16.0.0/28" |    no    |

## Outputs

| Name                   | Description                                                      |
| ---------------------- | ---------------------------------------------------------------- |
| cluster_id             | The ID of the cluster                                            |
| cluster_name           | The name of the cluster                                          |
| cluster_endpoint       | The IP address of the cluster's master endpoint                  |
| cluster_ca_certificate | The public certificate that is the root of trust for the cluster |
