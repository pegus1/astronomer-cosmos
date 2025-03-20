# Provider
terraform {
  required_version = ">= 1.11.0" # Ensure that the Terraform version is 1.0.0 or higher

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.24"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.24"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider google-beta {
  project = var.project_id
  region  = var.region
}