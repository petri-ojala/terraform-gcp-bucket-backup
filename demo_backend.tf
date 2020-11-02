#
# Create the Terraform state bucket first: (chicken and egg..)
#
# gsutil mb -l EU gs://gcs_demo_terraform_state
# gsutil versioning set on gs://gcs_demo_terraform_state
#

variable gcs_tfstate_bucket {
  type    = string
  default = "gcs_demo_terraform_state"
}

variable gcs_tfstate_backup_bucket {
  type    = string
  default = "gcs_demo_terraform_state_backup"
}

#
# Backup bucket for Terraform state

resource "google_storage_bucket" "tfstate_backup" {
  name                        = var.gcs_tfstate_backup_bucket
  project                     = var.gcp_project_id
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

#
# GCS Bucket Backup Cloud Function for Terraform state

resource "google_cloudfunctions_function" "gcs_tfstate_backup_function" {
  name        = "GCSBucketBackup-tfstate"
  description = "GCS Bucket backup for tfstate"
  region      = var.gcp_function_region
  runtime     = "go111"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.source_code.name
  source_archive_object = google_storage_bucket_object.source_code.name
  timeout               = 60
  entry_point           = "GCSBucketBackup"

  environment_variables = {
    DEST_BUCKET = var.gcs_tfstate_backup_bucket
  }

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = var.gcs_tfstate_bucket
  }
}

#
# IAM permissions for Cloud Function to access buckets

resource "google_storage_bucket_iam_member" "function_tfstate_source" {
  bucket = var.gcs_tfstate_bucket
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_cloudfunctions_function.gcs_tfstate_backup_function.service_account_email}"
}

resource "google_storage_bucket_iam_member" "function_tfstate_destination" {
  bucket = var.gcs_tfstate_backup_bucket
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_cloudfunctions_function.gcs_tfstate_backup_function.service_account_email}"
}

#
# And finally, define backend for Terraform state

terraform {
  backend "gcs" {
    # bucket should be the same as var.gcs_tfstate_bucket
    bucket = "gcs_demo_terraform_state"
    prefix = "tfstate"
  }
}
