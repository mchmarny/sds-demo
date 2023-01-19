locals {
  # List of roles that will be assigned to the runner service account
  runner_roles = toset([
    "roles/artifactregistry.reader",
    "roles/binaryauthorization.attestorsViewer",
    "roles/cloudkms.cryptoKeyDecrypter",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/cloudkms.publicKeyViewer",
    "roles/cloudkms.signerVerifier",
    "roles/containeranalysis.notes.viewer",
    "roles/containeranalysis.notes.occurrences.viewer",
  ])
}

# Set up deploy_sa. Used to verify built images.
resource "google_service_account" "runner_sa" {
  account_id   = format("%s-runner-sa", var.root_name)
  display_name = "Cluster Runner Service Account"
}

resource "google_project_iam_member" "runner_role_binding" {
  for_each = local.runner_roles
  project  = data.google_project.project.project_id
  role     = each.value
  member   = format("serviceAccount:%s", google_service_account.runner_sa.email)
}

resource "google_service_account_iam_member" "test_cluster_role_binding" {
  service_account_id = google_service_account.runner_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = format("serviceAccount:%s.svc.id.goog[default/default]", data.google_project.project.project_id)
}

# Test cluster
resource "google_container_cluster" "test_cluster" {
  name                     = format("%s-test", var.root_name)
  location                 = format("%s-%s", var.region, var.zone)
  remove_default_node_pool = true
  initial_node_count       = 1

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = format("%s.svc.id.goog", data.google_project.project.project_id)
  }

  cluster_autoscaling {
    enabled = true

    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 32
    }

    resource_limits {
      resource_type = "memory"
      minimum       = 4
      maximum       = 64
    }

    auto_provisioning_defaults {
      image_type = "COS_CONTAINERD"
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  resource_labels = {
    "environment" = "demo"
    "demo"        = "build"
  }
}


resource "google_container_node_pool" "test_cluster_nodes" {
  name       = format("%s-test-pool", var.root_name)
  cluster    = google_container_cluster.test_cluster.id
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.runner_sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      "environment" = "demo"
      "demo"        = "build"
    }

    gcfs_config {
      enabled = true
    }
  }

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}


# Test cluster
resource "google_container_cluster" "prod_cluster" {
  name                     = format("%s-prod", var.root_name)
  location                 = format("%s-%s", var.region, var.zone)
  remove_default_node_pool = true
  initial_node_count       = 1

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = format("%s.svc.id.goog", data.google_project.project.project_id)
  }

  cluster_autoscaling {
    enabled = true

    resource_limits {
      resource_type = "cpu"
      minimum       = 1
      maximum       = 32
    }

    resource_limits {
      resource_type = "memory"
      minimum       = 4
      maximum       = 64
    }

    auto_provisioning_defaults {
      image_type = "COS_CONTAINERD"
    }
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    http_load_balancing {
      disabled = false
    }

    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
  }

  resource_labels = {
    "environment" = "demo"
    "demo"        = "build"
  }
}


resource "google_container_node_pool" "prod_cluster_nodes" {
  name       = format("%s-prod-pool", var.root_name)
  cluster    = google_container_cluster.prod_cluster.id
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  node_config {
    machine_type    = "e2-medium"
    service_account = google_service_account.runner_sa.email

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      "environment" = "demo"
      "demo"        = "build"
    }

    gcfs_config {
      enabled = true
    }
  }

  lifecycle {
    ignore_changes = [
      node_count
    ]
  }
}
