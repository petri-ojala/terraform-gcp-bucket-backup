#
# Some demo objects to play with..

resource "google_storage_bucket_object" "demo_object_1" {
  for_each = var.gcs_buckets

  name   = "demo_buckets.tf"
  source = "./demo_buckets.tf"
  bucket = each.value
<<<<<<< HEAD

  depends_on = [
    google_storage_bucket.source
  ]
=======
>>>>>>> 18d1590ad0254780a6ef89678c911e8d29fc29e1
}

resource "google_storage_bucket_object" "demo_object_2" {
  for_each = var.gcs_buckets

  name   = "demo_objects.tf"
  source = "./demo_objects.tf"
  bucket = each.value
<<<<<<< HEAD

  depends_on = [
    google_storage_bucket.source
  ]
=======
>>>>>>> 18d1590ad0254780a6ef89678c911e8d29fc29e1
}
