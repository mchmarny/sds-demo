# List of variables which can be provided ar runtime to override the specified defaults 

variable "root_name" {
  description = "Root name to key off variables"
  type        = string
  default     = "demo"
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
  nullable    = false
}

variable "region" {
  description = "GCP Region"
  type        = string
  nullable    = false
}

variable "zone" {
  description = "GCP Region Zone"
  type        = string
  nullable    = false
}

variable "github_repo_owner" {
  description = "The owner of the GitHub repo"
  type        = string
  nullable    = false
}

variable "github_repo_name" {
  description = "The name of the GitHub repo"
  type        = string
  nullable    = false
}