provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_address" "vm_ip" {
  name   = "${var.goog_cm_deployment_name}-ip"
  region = var.region
}

resource "google_compute_firewall" "allow_tcp_3001" {
  name    = "${var.goog_cm_deployment_name}-tcp-3001"
  network = var.network

  allow {
    protocol = "tcp"
    ports    = ["3001"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.goog_cm_deployment_name}-deployment"]
}

resource "google_compute_instance" "vm_instance" {
  name         = "${var.goog_cm_deployment_name}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network = var.network

    access_config {
      nat_ip = google_compute_address.vm_ip.address
    }
  }

  service_account {
    email = "default"
    scopes = [
      "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  tags = ["${var.goog_cm_deployment_name}-deployment"]

  metadata = {
    startup-script = <<-EOT
      #!/bin/bash

      set -e

      LOCK_FILE="/etc/bindplane/provision.lock"

      if test -f "$LOCK_FILE"; then
          echo "BindPlane is already configured. Skipping startup script."
          exit 0
      fi

      cat << CONFIG > /etc/bindplane/config.yaml
      license: "${var.license}"
      eula:
        accepted: "2023-05-30"
      mode:
      - all
      rolloutsInterval: 5s
      auth:
        type: system
        username: "admin"
        password: "$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c32;echo;)"
        sessionSecret: "$(uuidgen)"
      network:
        host: 0.0.0.0
        port: "3001"
        remoteURL: "http://${google_compute_address.vm_ip.address}:3001"
      agentVersions:
        syncInterval: 1h0m0s
        agentUpgradesFolder: /var/lib/bindplane/agent-upgrades
      store:
        type: postgres
        maxEvents: 100
        postgres:
          database: bindplane
      eventBus:
        type: local
      logging:
        filePath: /var/log/bindplane/bindplane.log
        output: file
      transformAgent:
        transformAgentsFolder: /var/lib/bindplane/transform-agents
      auditTrail:
        retentionDays: 30
      CONFIG

      sudo systemctl enable bindplane

      touch "$LOCK_FILE"
      chown root:root "$LOCK_FILE"
      chmod 0644 "$LOCK_FILE"
      cat << EOF > "$LOCK_FILE"
      BindPlane initialization successful. Removing this file
      will cause the Google Compute instance startup script to re-run
      on startup, causing the configuration file to change.
      EOF
    EOT
  }
}

variable "project_id" {
  type        = string
  description = "The ID of the Google Cloud project."
}

variable "goog_cm_deployment_name" {
  type        = string
  default     = "bindplane"
  description = "The name of the deployment."
}

variable "image" {
  type = string
  // TODO(jsirianni): Understand why a default is needed here
  // TODO(jsirianni): We should start using semver
  default     = "projects/blue-medoras-public-project/global/images/bindplane-ee-1-88-4"
  description = "The image to use for the boot disk."
}

variable "license" {
  type        = string
  default     = ""
  description = "The license key for the BindPlane software."
}

variable "region" {
  type        = string
  default     = "us-east1"
  description = "The region where the resources will be deployed."
}

variable "zone" {
  type        = string
  default     = "us-east1-b"
  description = "The zone where the instance will be created."
}

variable "machine_type" {
  type        = string
  default     = "n2-standard-2"
  description = "The machine type for the instance."
}

variable "network" {
  type        = string
  default     = "default"
  description = "The network to which the instance will be connected."
}

variable "boot_disk_size_gb" {
  type        = number
  default     = 120
  description = "The size of the boot disk in gigabytes."
}

variable "boot_disk_type" {
  type        = string
  default     = "pd-ssd"
  description = "The type of the boot disk."
}

output "endpoint" {
  description = "The external IP address of the instance formatted as a URL."
  value       = "http://${google_compute_address.vm_ip.address}:3001"
}

output "ssh_command" {
  description = "The gcloud command to SSH into the instance."
  value       = "gcloud compute ssh ${var.goog_cm_deployment_name}-vm --zone ${var.zone} --project ${var.project_id}"
}


