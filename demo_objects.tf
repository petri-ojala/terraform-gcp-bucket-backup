#
# Some demo objects to play with..

resource "google_storage_bucket_object" "demo_object_1" {
  for_each = var.gcs_buckets

  name   = "demo_buckets.tf"
  source = "./demo_buckets.tf"
  bucket = each.value
}

resource "google_storage_bucket_object" "demo_object_2" {
  for_each = var.gcs_buckets

  name   = "demo_objects.tf"
  source = "./demo_objects.tf"
  bucket = each.value
}
