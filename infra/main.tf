# Enable APIs
resource "google_project_service" "artifact_registry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "cloud_run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "bigquery" {
  service = "bigquery.googleapis.com"
}

# Artifact Registry Repository
resource "google_artifact_registry_repository" "repo" {
  provider      = google-beta
  location      = var.region
  repository_id = var.repo_name
  format        = "DOCKER"
  description   = "Docker repository for Astronomer Cosmos dbt images"
}

# Service Account
resource "google_service_account" "sa" {
  account_id   = var.service_account_name
  display_name = "Cloud Run Job Service Account"
}

# IAM Roles for Service Account
resource "google_project_iam_member" "bigquery_job_user" {
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.project_id
  depends_on = [google_service_account.sa]
}

resource "google_project_iam_member" "bigquery_data_editor" {
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.sa.email}"
  project = var.project_id
  depends_on = [google_service_account.sa]
}

# BigQuery Dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.dataset_name
  location   = var.region
  depends_on = [google_project_service.bigquery]
}

# Build Docker Image
resource "null_resource" "build_docker_image" {
  depends_on = [
    google_project_service.artifact_registry, google_project_service.cloud_run, google_artifact_registry_repository.repo
  ]
  provisioner "local-exec" {
    command = "cd ../ && docker build -t ${local.image_name} -f gcp_cloud_run_job/Dockerfile.gcp_cloud_run_job ."
  }
}

resource "null_resource" "image_push" {
  depends_on = [
    google_project_service.artifact_registry, google_project_service.cloud_run,
    google_artifact_registry_repository.repo, null_resource.build_docker_image
  ]
  provisioner "local-exec" {
    command = "docker push ${local.image_name}"
  }
}

# Cloud Run Job
resource "google_cloud_run_v2_job" "job" {
  name     = var.cloud_run_job_name
  location = var.region
  depends_on = [
    google_project_service.artifact_registry, google_project_service.cloud_run,
    google_artifact_registry_repository.repo, google_service_account.sa, null_resource.build_docker_image,
    null_resource.image_push
  ]

  template {
    template {
      containers {
        image = local.image_name
      }
      service_account = google_service_account.sa.email
    }
  }
}