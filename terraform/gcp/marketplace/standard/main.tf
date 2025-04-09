provider "google" {
  project = var.project_id
  region  = var.region
}

module "bindplane" {
  source = "./modules/single"

  project_id        = var.project_id
  goog_cm_deployment_name = var.goog_cm_deployment_name
  image             = var.image
  license           = var.license
  region            = var.region
  zone              = var.zone
  machine_type      = var.machine_type
  network           = var.network
  boot_disk_size_gb = var.boot_disk_size_gb
  boot_disk_type    = var.boot_disk_type
}
