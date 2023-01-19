# Configure Key Management Service.

locals {
  # List of roles that will be used by VERIFIER_SA to sign attestations
  attestation_roles = toset([
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
    "roles/cloudkms.cryptoOperator",
    "roles/cloudkms.publicKeyViewer",
    "roles/cloudkms.signerVerifier",
    "roles/cloudkms.viewer",
  ])
}

resource "google_kms_key_ring" "key_ring" {
  name     = format("%s-ring", var.root_name)
  location = var.region
}

# Private key for VERIFIER_SA to sign attestations.
resource "google_kms_crypto_key" "key" {
  name     = format("%s-key", var.root_name)
  key_ring = google_kms_key_ring.key_ring.id
  purpose  = "ASYMMETRIC_SIGN"

  version_template {
    algorithm = "RSA_SIGN_PKCS1_2048_SHA256"
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "google_kms_crypto_key_version" "key_version" {
  crypto_key = google_kms_crypto_key.key.id
}

resource "google_kms_crypto_key_iam_binding" "builder_key_binding" {
  for_each      = local.attestation_roles
  crypto_key_id = google_kms_crypto_key.key.id
  role          = each.value

  members = [
    format("serviceAccount:%s@cloudbuild.gserviceaccount.com", data.google_project.project.number),
  ]
}

resource "google_kms_crypto_key_iam_binding" "runner_key_binding" {
  for_each      = local.attestation_roles
  crypto_key_id = google_kms_crypto_key.key.id
  role          = each.value

  members = [
    format("serviceAccount:%s", google_service_account.runner_sa.email),
  ]
}
