resource "google_container_analysis_note" "builder_note" {
  project = var.project_id
  name = format("%s-builder-note", var.root_name)
  attestation_authority {
    hint {
      human_readable_name = "GCB Builder Attestor Note"
    }
  }
}

resource "google_binary_authorization_attestor" "builder_attestor" {
  project = var.project_id
  name    = format("%s-attestor", var.root_name)
  attestation_authority_note {
    note_reference = google_container_analysis_note.builder_note.name
    public_keys {
      id = data.google_kms_crypto_key_version.key_version.id
      pkix_public_key {
        public_key_pem      = data.google_kms_crypto_key_version.key_version.public_key[0].pem
        signature_algorithm = data.google_kms_crypto_key_version.key_version.public_key[0].algorithm
      }
    }
  }
}

resource "google_binary_authorization_attestor_iam_binding" "builder_binding" {
  project  = google_binary_authorization_attestor.builder_attestor.project
  attestor = google_binary_authorization_attestor.builder_attestor.name
  role     = "roles/binaryauthorization.attestorsViewer"
  members = [
    format("serviceAccount:%s@cloudbuild.gserviceaccount.com",
    data.google_project.project.number),
  ]
}


resource "google_binary_authorization_policy" "policy" {
  admission_whitelist_patterns {
    name_pattern = "gcr.io/google_containers/**"
  }
  admission_whitelist_patterns {
    name_pattern = "us.gcr.io/google-containers/**"
  }
  admission_whitelist_patterns {
    name_pattern = "gcr.io/stackdriver-agents/**"
  }
  admission_whitelist_patterns {
    name_pattern = "gke.gcr.io/**"
  }
  admission_whitelist_patterns {
    name_pattern = "us-west1-docker.pkg.dev/cloudy-labz/**"
  }
  admission_whitelist_patterns {
    name_pattern = "us-docker.pkg.dev/cloudy-demos/**"
  }

  default_admission_rule {
    evaluation_mode  = "ALWAYS_ALLOW"
    enforcement_mode = "ENFORCED_BLOCK_AND_AUDIT_LOG"
  }

  cluster_admission_rules {
    cluster                 = format("%s-%s.%s-test", var.region, var.zone, var.root_name)
    evaluation_mode         = "REQUIRE_ATTESTATION"
    enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    require_attestations_by = [google_binary_authorization_attestor.builder_attestor.name]
  }

  cluster_admission_rules {
    cluster                 = format("%s-%s.%s-prod", var.region, var.zone, var.root_name)
    evaluation_mode         = "REQUIRE_ATTESTATION"
    enforcement_mode        = "ENFORCED_BLOCK_AND_AUDIT_LOG"
    require_attestations_by = [google_binary_authorization_attestor.builder_attestor.name]
  }
}

