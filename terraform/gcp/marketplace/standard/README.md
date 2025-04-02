# Terraform Configuration for Google Compute Instance

This directory contains a Terraform configuration for deploying a Google Compute Engine instance.

## Prerequisites

### Required tools

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- Google Cloud SDK installed and authenticated.
- A Google Cloud project with billing enabled.
- Packer build completed as described in the [Google Marketplace README](../README.md).

### Required GCP IAM Roles

To deploy this Terraform configuration, the following IAM roles are required:

- **Compute Admin**: Allows full control of all Compute Engine resources, including VM instances, IP addresses, and firewall rules.
- **Service Account User**: Allows a user to act as a service account, necessary if service accounts are used in the configuration.

Ensure that the user deploying the Terraform configuration has these roles assigned in the Google Cloud project.

## Applying the Configuration

1. Initialize Terraform:

   ```bash
   terraform init
   ```

2. Plan the deployment to see what changes will be made:

   ```bash
   terraform plan \
     -var="project=your-gcp-project-id" \
     -var="deployment=your-deployment-name" \
     -var="network=default" \
     -var="subnetwork=default" \
     -var="image=bindplane-ee-<commit>"
   ```

3. Apply the configuration to create the resources:

   ```bash
   terraform apply \
     -var="project=your-gcp-project-id" \
     -var="deployment=your-deployment-name" \
     -var="network=default" \
     -var="subnetwork=default" \
     -var="image=bindplane-ee-<commit>"
   ```

Replace the variable values with your specific configuration.

## Using as a Module

This Terraform configuration can be used as a module in other Terraform configurations. To use it as a module, follow these steps:

1. **Include the Module**: Add the module to your Terraform configuration by specifying the source path and providing the necessary input variables.

   ```hcl
   module "compute_instance" {
     source = "./google_compute_instance_module"

     project           = "your-gcp-project-id"
     deployment        = "your-deployment-name"
     network           = "default"
     subnetwork        = "default"
     image             = "your-image"
     license           = "your-license"
     # Add other variables as needed
   }
   ```

2. **Initialize Terraform**: Run `terraform init` to initialize the module.

3. **Plan and Apply**: Use `terraform plan` and `terraform apply` to review and apply the changes.

## Variables

| Variable           | Description                                      | Default       |
|--------------------|--------------------------------------------------|---------------|
| `project`          | The ID of your Google Cloud project.            | required      |
| `region`           | The region where the resources will be deployed.| `us-east1`    |
| `deployment`       | The name of the deployment.                     | required      |
| `zone`             | The zone where the instance will be created.    | `us-east1-b`  |
| `machine_type`     | The machine type for the instance.              | `n2-standard-2`|
| `network`          | The network to which the instance will be connected.| required  |
| `subnetwork`       | The subnetwork to which the instance will be connected.| required|
| `image`            | The image to use for the boot disk.             | required      |
| `boot_disk_size_gb`| The size of the boot disk in gigabytes.         | `120`         |
| `boot_disk_type`   | The type of the boot disk.                      | `pd-ssd`      |
