# Add terraform block at the top of the file
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

# Enable required GCP APIs
resource "google_project_service" "required_apis" {
  for_each = toset([
    "compute.googleapis.com",              # Compute Engine API
    "container.googleapis.com",            # Kubernetes Engine API
    "servicenetworking.googleapis.com",    # Service Networking API
    "cloudresourcemanager.googleapis.com", # Cloud Resource Manager API
    "containerregistry.googleapis.com",    # Container Registry API
    "sqladmin.googleapis.com",             # Cloud SQL Admin API
  ])

  project = var.project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy         = false
}
