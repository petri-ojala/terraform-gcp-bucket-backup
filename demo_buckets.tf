#
# Create demo buckets (both source and destination)

resource "google_storage_bucket" "source" {
  for_each = var.gcs_buckets

  name                        = each.value
  project                     = var.gcp_project_id
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

resource "google_storage_bucket" "destination" {
  for_each = var.gcs_buckets

  name                        = each.key
  project                     = var.gcp_project_id
  force_destroy               = true
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}
