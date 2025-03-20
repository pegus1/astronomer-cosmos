# Variables
variable "project_id" {
  description = "The ID of your GCP project"
  type        = string
  default     = "ingka-dp-sap-dev"
}

variable "region" {
  description = "The GCP region for your resources"
  type        = string
  default     = "europe-west1"
}

variable "repo_name" {
  description = "Name of the Artifact Registry repository"
  type        = string
  default     = "astronomer-cosmos"
}

variable "service_account_name" {
  description = "Name of the service account"
  type        = string
  default     = "dbt-service-account"
}

variable "dataset_name" {
  description = "Name of the BigQuery dataset"
  type        = string
  default     = "astronomer_cosmos"
}

locals {
  image_name = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repo_name}/astronomer-cosmos"
}

variable "cloud_run_job_name" {
  description = "Name of the Cloud Run Job"
  type        = string
  default     = "astronomer-cosmos"
}