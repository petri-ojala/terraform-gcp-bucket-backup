#
# Example configuration parameters

#
# map(string) where key is the destination bucket and value is the source bucket

gcs_buckets = {
  gcs_demo_dest_bucket1 = "gcs_demo_source_bucket1"
  gcs_demo_dest_bucket2 = "gcs_demo_source_bucket2"
}

#
# GCP Environment

gcp_project_id = "pojala-gcp-playground"
gcp_region     = "europe-north1"

#
# GCP Bucket name for the Cloud Functions code

gcf_source_bucket = "terraform-gcf-bucket-backup"
