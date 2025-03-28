# Add terraform block at the top of the file
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.25.0"
    }
  }
}

# Base VPC and networking configuration for Bindplane

locals {
  network_name        = var.network_name != "" ? var.network_name : "bindplane-network"
  subnet_name         = "${local.network_name}-subnet"
  pods_range_name     = "pods"
  services_range_name = "services"
  router_name         = "${local.network_name}-router"
  nat_name            = "${local.network_name}-nat"
}

resource "google_compute_network" "vpc" {
  name                    = local.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
}

resource "google_compute_subnetwork" "subnet" {
  name          = local.subnet_name
  ip_cidr_range = var.subnet_ip_range
  network       = google_compute_network.vpc.id
  region        = var.region
  project       = var.project_id

  # Secondary ranges for GKE
  secondary_ip_range {
    range_name    = local.pods_range_name
    ip_cidr_range = var.pods_ip_range
  }

  secondary_ip_range {
    range_name    = local.services_range_name
    ip_cidr_range = var.services_ip_range
  }

  private_ip_google_access = true

  #checkov:skip=CKV_GCP_26: "Out of scope for now"
}

# Cloud NAT for outbound internet access
resource "google_compute_router" "router" {
  name    = local.router_name
  network = google_compute_network.vpc.id
  region  = var.region
  project = var.project_id
}

resource "google_compute_router_nat" "nat" {
  name                               = local.nat_name
  router                             = google_compute_router.router.name
  region                             = var.region
  project                            = var.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# Private Service Access for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${local.network_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Add basic firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "${local.network_name}-allow-internal"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
  }
  allow {
    protocol = "udp"
  }

  source_ranges = [
    var.subnet_ip_range,
    var.pods_ip_range,
    var.services_ip_range
  ]
}

# Allow health checks
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${local.network_name}-allow-health-checks"
  network = google_compute_network.vpc.name
  project = var.project_id

  allow {
    protocol = "tcp"
  }

  source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]
}
