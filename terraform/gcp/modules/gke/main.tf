# At the top of the file
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.25.0"
    }
  }
}

# Basic GKE cluster configuration
locals {
  cluster_name   = "${var.cluster_name}-cluster"
  node_pool_name = "${var.cluster_name}-node-pool"
  workload_pool  = "${var.project_id}.svc.id.goog"

  base_labels = {
    environment                             = var.environment
    "goog-gke-node-pool-provisioning-model" = "on-demand"
  }
}

resource "google_container_cluster" "primary" {
  name     = local.cluster_name
  location = var.region
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network_name
  subnetwork = var.subnet_name

  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_ip_range_name
    services_secondary_range_name = var.services_ip_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  workload_identity_config {
    workload_pool = local.workload_pool
  }

  node_config {
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  }

  release_channel {
    channel = "REGULAR"
  }

  enable_intranode_visibility = true

  network_policy {
    enabled = true
  }

  #checkov:skip=CKV_GCP_20: "TODO(jsirianni): We can make this opt in"
  #checkov:skip=CKV_GCP_21: "TODO(jsirianni): We can make this opt in"
  #checkov:skip=CKV_GCP_13: "TODO(jsirianni): We can make this opt in"
  #checkov:skip=CKV_GCP_65: Out of scope for now
  #checkov:skip=CKV_GCP_66: Out of scope for now
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name               = local.node_pool_name
  location           = var.region
  cluster            = google_container_cluster.primary.name
  project            = var.project_id
  initial_node_count = var.initial_node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb

    service_account = var.node_service_account
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Explicit label management
    resource_labels = merge(local.base_labels, var.additional_node_labels)

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  lifecycle {
    ignore_changes = [
      node_config[0].resource_labels["goog-gke-node-pool-provisioning-model"],
      node_config[0].kubelet_config,
    ]
  }
}
