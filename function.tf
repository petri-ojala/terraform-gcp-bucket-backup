#
# Create the Cloud Functions to backup each bucket

#
# GCS Bucket for GCF Function source code

resource "google_storage_bucket" "source_code" {
  name                        = var.gcf_source_bucket
  project                     = var.gcp_project_id
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }
}

#
# ZIP golang source code to the bucket

data "archive_file" "code" {
  type        = "zip"
  output_path = "${path.module}/${var.gcp_source_zip_name}"

  source {
    content  = "${file("${path.module}/gcs_bucket_backup.go")}"
    filename = "gcs_bucket_backup.go"
  }

  source {
    content  = "${file("${path.module}/go.mod")}"
    filename = "go.mod"
  }
}

#
# Store zip to GCS Bucket for Cloud Functions

resource "google_storage_bucket_object" "source_code" {
  name       = var.gcp_source_zip_name
  bucket     = google_storage_bucket.source_code.name
  source     = "${path.module}/${var.gcp_source_zip_name}"
  depends_on = [data.archive_file.code]
}

#
# GCS Bucket Backup Cloud Function for each source bucket
#
# The function gets the source bucket and object details from the event
# Destination bucket is defined by environment variable DEST_BUCKET
#

resource "google_cloudfunctions_function" "gcs_backup_function" {
  for_each = var.gcs_buckets

  name        = "GCSBucketBackup-${each.value}"
  description = "GCS Bucket backup for ${each.value}"
  region      = var.gcp_function_region
  runtime     = "go111"

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.source_code.name
  source_archive_object = google_storage_bucket_object.source_code.name
  timeout               = 60
  entry_point           = "GCSBucketBackup"

  environment_variables = {
    DEST_BUCKET = each.key
  }

  event_trigger {
    event_type = "google.storage.object.finalize"
    resource   = each.value
  }
}

#
# IAM permissions for Cloud Functions to access buckets
#
# Cloud Functions needs to be able to read the source bucket and object, and store the object to the 
# destination bucket.
#

resource "google_storage_bucket_iam_member" "function_source" {
  for_each = var.gcs_buckets

  bucket = each.value
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_cloudfunctions_function.gcs_backup_function[each.key].service_account_email}"
}

resource "google_storage_bucket_iam_member" "function_destination" {
  for_each = var.gcs_buckets

  bucket = each.key
  role   = "roles/storage.objectCreator"
  member = "serviceAccount:${google_cloudfunctions_function.gcs_backup_function[each.key].service_account_email}"
}
