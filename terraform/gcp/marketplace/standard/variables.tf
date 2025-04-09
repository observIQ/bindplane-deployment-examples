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
