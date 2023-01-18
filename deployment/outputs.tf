# List of outputs from each terraform apply 

output "PROJECT_ID" {
  value       = data.google_project.project.name
  description = "GCP project ID."
}

output "PROHECT_NUMBER" {
  value       = data.google_project.project.number
  description = "GCP project number."
}

output "PROHECT_REGION" {
  value       = var.region
  description = "GCP project region."
}

output "TEKTON_BUILDER_SA" {
  value       = var.builder_sa
  description = "GCP service account executing Tekton builds"
}

output "TEKTON_VERIFIER_SA" {
  value       = var.verifier_sa
  description = "GCP service account use to invoke image verifications"
}

