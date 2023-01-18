# Set up deploy_sa. Used to verify built images.
resource "google_service_account" "runner_sa" {
  account_id   = "${var.root_name}-runner-sa"
  display_name = "Cluster Runner Service Account"
}

# GKE with Workload Identity, Binary Authorization, and Image Streaming
# Workload Identity maps SA in k8s to BUILDER_SA.
# https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
# Image Streaming enables faster loading of containers.
# https://cloud.google.com/kubernetes-engine/docs/how-to/image-streaming

resource "google_container_cluster" "rest_cluster" {
  name     = "${var.root_name}-test"
  location = "${var.region}-${var.zone}"

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  binary_authorization {
    evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  }

  release_channel {
    channel = "REGULAR"
  }

  workload_identity_config {
    workload_pool = "${data.google_project.project.project_id}.svc.id.goog"
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

  resource_labels = {
    "environment" = "demo"
    "demo"        = "tekton"
  }
}


resource "google_container_node_pool" "cluster_nodes" {
  name       = "${var.cluster_name}-pool"
  cluster    = google_container_cluster.cluster.id
  node_count = 3

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = 1
    max_node_count = 5
  }

  node_config {
    machine_type = var.node_type
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = {
      "environment" = "demo"
      "demo"        = "tekton"
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

resource "google_service_account_iam_member" "cluster_role_binding" {
  service_account_id = google_service_account.builder_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${data.google_project.project.project_id}.svc.id.goog[default/default]"
}
