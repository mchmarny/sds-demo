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

output "GITHUB_REPO" {
  value       = "${var.github_repo_owner}/${var.github_repo_name}"
  description = "Fully qualified GitHub repo that will trigger Cloud Build"
}
