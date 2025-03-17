locals {
  namespace       = "bindplane"
  database_name   = "bindplane"
  database_user   = "bindplane"
  admin_username  = "admin"
  environment     = "development"
  machine_type    = "n2-standard-4"
  initial_nodes   = 1
  min_nodes       = 1
  max_nodes       = 6
  disk_size_gb    = 500
  instance_tier   = "db-custom-4-15360"
  max_connections = 400
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

module "pubsub" {
  depends_on = [module.project_setup]
  source = "../../modules/pubsub"

  project_id = var.project_id
  topic_name = var.cluster_name
}

module "gke" {
  depends_on = [
    module.project_setup,
    module.networking
  ]
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
  depends_on = [module.project_setup]
  account_id   = "${var.cluster_name}-sa"
  display_name = "GKE Service Account"
  project      = var.project_id
}

# Add after service account creation
resource "google_project_iam_member" "gke_sa_roles" {
  depends_on = [module.project_setup]
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

# Create service account for Bindplane Workload Identity Federation
resource "google_service_account" "bindplane" {
  depends_on = [module.project_setup]
  account_id   = "${var.cluster_name}-bindplane-sa"
  display_name = "Bindplane Service Account"
  project      = var.project_id
}


# IAM Policy Binding: Allow Kubernetes service account to impersonate the GCP service account
resource "google_service_account_iam_binding" "bindplane_workload_identity" {
  depends_on = [module.project_setup, module.gke]
  service_account_id = google_service_account.bindplane.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${local.namespace}/bindplane]"
  ]
}

# Grant Pub/Sub permissions to the service account
resource "google_project_iam_member" "bindplane_pubsub_permissions" {
  depends_on = [module.project_setup]
  for_each = toset([
    // TODO(jsirianni): This is invasive, because Bindplane attempts to create a topic
    // on startup while checking if it exists. We can optimize this check to avoid this
    // IAM requirement in the future.
    "roles/pubsub.admin",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.bindplane.email}"
}

// Grant permission to subscribe and publish the topic. This is scoped
// to the topic itself, not the project.
resource "google_pubsub_topic_iam_binding" "bindplane_pubsub_topic_permissions" {
  depends_on = [module.project_setup]
  topic = module.pubsub.topic_name
  role  = "roles/pubsub.publisher"

  members = [
    "serviceAccount:${google_service_account.bindplane.email}"
  ]
}

# Add after the GKE module
module "cloudsql" {
  depends_on = [module.gke, module.project_setup]
  source     = "../../modules/cloudsql"

  project_id        = var.project_id
  region            = var.region
  network_id        = module.networking.network_id
  instance_name     = var.cluster_name
  database_name     = local.database_name
  database_user     = local.database_user
  database_password = var.database_password
  max_connections   = local.max_connections

  # Optional overrides
  instance_tier       = local.instance_tier
  disk_size_gb        = local.disk_size_gb
  deletion_protection = false # Easier cleanup for testing
}

resource "random_uuid" "bindplane_session" {}

resource "google_compute_global_address" "bindplane_ip" {
  depends_on = [module.project_setup]
  name         = "${var.cluster_name}-external-ip"
  address_type = "EXTERNAL"
}
