#
# Google Cloud

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

#
# Archive provider to create zip archives

provider "archive" {
}

#
# Version requirements

terraform {
  required_version = "~> 0.13.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.44"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0.0"
    }
  }
}
