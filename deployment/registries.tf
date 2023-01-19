resource "google_artifact_registry_repository" "registry" {
  repository_id = var.root_name
  location      = var.region
  description   = "Demo registry"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_binding" "binding" {
  project    = google_artifact_registry_repository.registry.project
  location   = google_artifact_registry_repository.registry.location
  repository = google_artifact_registry_repository.registry.name
  role       = "roles/artifactregistry.repoAdmin"
  members = [
    format("serviceAccount:%s@cloudbuild.gserviceaccount.com",
    data.google_project.project.number),
  ]
}
