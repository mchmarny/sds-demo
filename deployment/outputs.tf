# List of outputs from each terraform apply 

output "PROJECT_ID" {
  value       = data.google_project.project.name
  description = "GCP project ID."
}

output "PROJECT_NUMBER" {
  value       = data.google_project.project.number
  description = "GCP project number."
}

output "PROJECT_REGION" {
  value       = var.region
  description = "GCP project region."
}

output "BUILDER_SA" {
  value       = google_service_account.builder_sa.email
  description = "GCP service account under which Cloud Build runs"
}

output "DEPLOYER_SA" {
  value       = google_service_account.deployer_sa.email
  description = "GCP service account under which Cloud Deploy runs"
}

output "RUNNER_SA" {
  value       = google_service_account.runner_sa.email
  description = "GCP service account under which GKE runs"
}
