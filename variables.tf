#
# Buckets to replicate

variable gcs_buckets {
  type        = map(string)
  description = "List of all buckets to replicate, key = destination, value = source"
}

#
# GCS Bucket for function's source code

variable gcf_source_bucket {
  type        = string
  description = "GCS Bucket for function's source code"
}

#
# Zip name for Cloud Functions source code

variable gcp_source_zip_name {
  type        = string
  description = "Filename for zip to contain the source code"
  default     = "gcs-bucket-backup.zip"
}

#
# GCP Project and Region for resources

variable gcp_project_id {
  type        = string
  description = "GCP Project ID"
}

variable gcp_region {
  type        = string
  description = "GCP Region"
}

# All GCP regions do not support Cloud Functions
# https://cloud.google.com/functions/docs/locations
variable gcp_function_region {
  type        = string
  description = "Region for Cloud Functions"
  default     = "europe-west1"
}
