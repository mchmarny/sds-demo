# List of GCP APIs to enable in this project
locals {
  services = [
    "artifactregistry.googleapis.com",
    "binaryauthorization.googleapis.com",
    "cloudasset.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouddeploy.googleapis.com",
    "cloudkms.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "compute.googleapis.com",
    "compute.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerfilesystem.googleapis.com",
    "containerregistry.googleapis.com",
    "containerscanning.googleapis.com",
    "containersecurity.googleapis.com",
    "iam.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "iamcredentials.googleapis.com",
    "monitoring.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceconsumermanagement.googleapis.com",
    "servicecontrol.googleapis.com",
    "servicemanagement.googleapis.com",
    "servicenetworking.googleapis.com",
    "serviceusage.googleapis.com",
    "stackdriver.googleapis.com",
    "storage-api.googleapis.com",
    "storage-component.googleapis.com",
  ]

  identities = [
    "binaryauthorization.googleapis.com",
    "cloudbuild.googleapis.com",
    "clouddeploy.googleapis.com",
    "container.googleapis.com",
    "cloudkms.googleapis.com",
  ]
}

# Data source to access GCP project metadata 
data "google_project" "project" {}

resource "google_project_service" "default" {
  for_each = toset(local.services)

  project = var.project_id
  service = each.value

  disable_on_destroy = false
  disable_dependent_services = false
}

resource "google_project_service_identity" "service_identity" {
  for_each = toset(local.identities)
  provider = google-beta
  project  = data.google_project.project.project_id
  service  = each.value
}