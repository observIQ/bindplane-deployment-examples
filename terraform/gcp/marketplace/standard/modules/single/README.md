# Terraform Configuration for Google Compute Instance

This directory contains a Terraform configuration for deploying a Google Compute Engine instance. While it
can be deployed manually, it is primarily intended for use with the [Google Cloud Marketplace](https://console.cloud.google.com/marketplace/product/bluemedora/bindplane-enterprise-edition).

## Prerequisites

### Required tools

- [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.
- Google Cloud SDK installed and authenticated.
- A Google Cloud project with billing enabled.

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
     -var="project_id=your-gcp-project-id" \
     -var="goog_cm_deployment_name=your-deployment-name"
   ```

3. Apply the configuration to create the resources:

   ```bash
   terraform apply \
     -var="project_id=your-gcp-project-id" \
     -var="goog_cm_deployment_name=your-deployment-name"
   ```

Replace the variable values with your specific configuration.

## Post-Deployment Steps

1. **Access the System**: Use the `ssh_command` output to SSH into the instance.

2. **Initialize License**: If you did not provide a license, run the following command:

   ```bash
   sudo BINDPLANE_CONFIG_HOME=/var/lib/bindplane /usr/local/bin/bindplane init license --config /etc/bindplane/config.yaml
   ```

   The init command will prompt you to restart the server. Choose 'yes'.

3. **Start the Service**: If you skipped the license initialization because a license was already configured, start the service manually:

   ```bash
   sudo systemctl enable bindplane
   sudo systemctl restart bindplane
   ```

4. **Inspect Config File**: Check the config file at `/etc/bindplane/config.yaml` for your password under `auth.password`. Use the username "admin" and your password to access the endpoint provided in the `endpoint` Terraform output.

## Using as a Module

This Terraform configuration can be used as a module in other Terraform configurations. To use it as a module, follow these steps:

1. **Include the Module**: Add the module to your Terraform configuration by specifying the source path and providing the necessary input variables.

   ```hcl
   module "compute_instance" {
     source = "./google_compute_instance_module"

     project_id           = "your-gcp-project-id"
     goog_cm_deployment_name = "your-deployment-name"
     # Add other variables as needed
   }
   ```

2. **Initialize Terraform**: Run `terraform init` to initialize the module.

3. **Plan and Apply**: Use `terraform plan` and `terraform apply` to review and apply the changes.

## Variables

| Variable           | Description                                      | Default       |
|--------------------|--------------------------------------------------|---------------|
| `project_id`       | The ID of your Google Cloud project.             | required      |
| `goog_cm_deployment_name` | The name of the deployment.               | `bindplane`   |
| `region`           | The region where the resources will be deployed. | `us-east1`    |
| `zone`             | The zone where the instance will be created.     | `us-east1-b`  |
| `machine_type`     | The machine type for the instance.               | `n2-standard-2`|
| `network`          | The network to which the instance will be connected.| `default`  |
| `image`            | The image to use for the boot disk.              | `projects/blue-medoras-public-project/global/images/bindplane-ee-1-88-4` |
| `boot_disk_size_gb`| The size of the boot disk in gigabytes.          | `120`         |
| `boot_disk_type`   | The type of the boot disk.                       | `pd-ssd`      |
| `license`          | The license key for the BindPlane software.      | optional         |

## Outputs

After applying the configuration, the following outputs will be available:

- **endpoint**: The external IP address of the instance formatted as a URL. You can access the application at this URL.
- **ssh_command**: The `gcloud` command to SSH into the instance. Use this command to connect to your instance via SSH.
