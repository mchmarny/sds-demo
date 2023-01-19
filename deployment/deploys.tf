locals {
  # List of roles that will be assigned to the deployer service account
  deployer_roles = toset([
    "roles/clouddeploy.jobRunner",
    "roles/clouddeploy.releaser",
    "roles/container.developer",
    "roles/iam.serviceAccountUser",
  ])
}

resource "google_project_iam_member" "deployer_role_binding" {
  for_each = local.deployer_roles
  project  = data.google_project.project.project_id
  role     = each.value
  member = format("serviceAccount:service-%s@gcp-sa-clouddeploy.iam.gserviceaccount.com",
  data.google_project.project.number)
}

resource "google_clouddeploy_target" "test_target" {
  name        = format("%s-test", var.root_name)
  location    = var.region
  description = "test cluster"
  project     = var.project_id

  gke {
    cluster = format("projects/%s/locations/%s/clusters/%s-test",
    var.project_id, var.region, var.root_name)
  }

  require_approval = false
}

resource "google_clouddeploy_target" "prod_target" {
  name        = format("%s-prod", var.root_name)
  location    = var.region
  description = "prod cluster"
  project     = var.project_id

  gke {
    cluster = format("projects/%s/locations/%s/clusters/%s-prod",
    var.project_id, var.region, var.root_name)
  }

  require_approval = true
}

resource "google_clouddeploy_delivery_pipeline" "release_pipeline" {
  location    = var.region
  name        = format("%s-release-pipeline", var.root_name)
  description = "Security-focused CI/CD pipeline on GCP"
  project     = var.project_id

  serial_pipeline {
    stages {
      profiles  = ["test"] # Skaffold profiles to use when rendering the manifest
      target_id = google_clouddeploy_target.test_target.name
    }

    stages {
      profiles  = ["prod"]
      target_id = google_clouddeploy_target.prod_target.name
    }
  }
}