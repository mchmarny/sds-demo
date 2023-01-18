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

# Create builder_sa. Used to builder_sa all GCP API invications during build.
resource "google_service_account" "builder_sa" {
  account_id   = "${var.root_name}-builder-sa"
  display_name = "Builder Service Account"
}


resource "google_project_iam_member" "builder_role_binding" {
  for_each = local.builder_roles
  project  = data.google_project.project.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.builder_sa.email}"
}