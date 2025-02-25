locals {
  namespace      = "bindplane"
  database_name  = "bindplane"
  database_user  = "bindplane"
  admin_username = "admin"
  environment    = "development"
  machine_type   = "e2-standard-2"
  initial_nodes  = 1
  min_nodes      = 1
  max_nodes      = 3
  disk_size_gb   = 10
  instance_tier  = "db-f1-micro"
}

module "project_setup" {
  source     = "../../modules/project-setup"
  project_id = var.project_id
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "networking" {
  depends_on = [module.project_setup]
  source     = "../../modules/networking"

  project_id = var.project_id
  region     = var.region

  # Optional overrides
  network_name      = var.network_name
  subnet_ip_range   = var.subnet_ip_range
  pods_ip_range     = var.pods_ip_range
  services_ip_range = var.services_ip_range
}

module "gke" {
  depends_on = [module.project_setup]
  source     = "../../modules/gke"

  project_id             = var.project_id
  region                 = var.region
  cluster_name           = var.cluster_name
  network_name           = module.networking.network_name
  subnet_name            = module.networking.subnet_name
  pods_ip_range_name     = module.networking.pods_ip_range_name
  services_ip_range_name = module.networking.services_ip_range_name

  # Optional overrides
  machine_type         = local.machine_type
  initial_node_count   = local.initial_nodes
  min_node_count       = local.min_nodes
  max_node_count       = local.max_nodes
  environment          = local.environment
  node_service_account = google_service_account.gke_sa.email
  additional_node_labels = {
    "app" = "bindplane"
  }
}

# Create service account for GKE nodes
resource "google_service_account" "gke_sa" {
  account_id   = "${var.cluster_name}-sa"
  display_name = "GKE Service Account"
  project      = var.project_id
}

# Add after service account creation
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer"
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# Add after the GKE module
module "cloudsql" {
  source = "../../modules/cloudsql"

  project_id        = var.project_id
  region            = var.region
  network_id        = module.networking.network_id
  instance_name     = var.cluster_name
  database_name     = local.database_name
  database_user     = local.database_user
  database_password = var.database_password

  # Optional overrides
  instance_tier       = local.instance_tier
  disk_size_gb        = local.disk_size_gb
  deletion_protection = false # Easier cleanup for testing
}

module "helm_config" {
  source = "../../modules/helm-config"
  providers = {
    helm.gke       = helm.gke
    kubernetes.gke = kubernetes.gke
  }

  namespace         = local.namespace
  admin_username    = local.admin_username
  admin_password    = var.admin_password
  sessions_secret   = random_uuid.bindplane_session.result
  license_key       = var.bindplane_license
  database_host     = module.cloudsql.private_ip_address
  database_name     = local.database_name
  database_user     = local.database_user
  database_password = var.database_password

  depends_on = [module.gke]
}

resource "random_uuid" "bindplane_session" {}

module "k8s_config" {
  source = "../../modules/k8s-config"

  providers = {
    kubernetes.gke = kubernetes.gke
  }

  namespace         = local.namespace
  database_host     = module.cloudsql.private_ip_address
  database_user     = local.database_user
  database_password = var.database_password
  database_name     = local.database_name

  depends_on = [module.gke]
}
