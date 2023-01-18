locals {
  # List of roles that will be assigned to the builder service account
  builder_roles = toset([
    "roles/artifactregistry.reader",
    "roles/artifactregistry.writer",
    "roles/binaryauthorization.attestorsViewer",
    "roles/clouddeploy.operator",
    "roles/cloudkms.cryptoKeyDecrypter",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/cloudkms.publicKeyViewer",
    "roles/cloudkms.signerVerifier",
    "roles/containeranalysis.notes.attacher",
    "roles/containeranalysis.notes.editor",
    "roles/containeranalysis.notes.occurrences.viewer",
    "roles/containeranalysis.occurrences.editor",
  ])
}

resource "google_project_iam_member" "builder_role_binding" {
  for_each = local.builder_roles
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${data.google_project.project.number}@cloudbuild.gserviceaccount.com"
}

resource "google_cloudbuild_worker_pool" "pool" {
  name     = "${var.root_name}-pool"
  location = var.region
  worker_config {
    disk_size_gb   = 100
    machine_type   = "e2-standard-2"
    no_external_ip = false
  }
}

resource "google_cloudbuild_trigger" "build_trigger" {
  name     = "${var.root_name}-build-trigger"
  location = var.region

  github {
    owner = var.github_repo_owner
    name  = var.github_repo_name
    push {
      tag = "v*"
    }
  }

  substitutions = {
    _KMS_DIGEST_ALG = "SHA512"
    _KMS_KEY_NAME   = data.google_kms_crypto_key_version.key_version.id
    _NOTE_NAME      = google_container_analysis_note.builder_note.name
    _BIN_AUTHZ_ID   = google_binary_authorization_attestor.builder_attestor.name
    _POOL_NAME      = google_cloudbuild_worker_pool.pool.name
  }

  filename = "app/cloudbuild.yaml"
}