# GCP Cloud Functions to replicate GCS bucket

Simple Cloud Functions (Cloud Function?) to copy changed objects from GCS bucket(s).  The cloud function is triggered by a `google.storage.object.finalize` event for the bucket and it will launch a small golang code to copy the changed object to a new bucket.

GCP provides Cloud Storage Transfer Service that can be used to transfer objects between GCS buckets but it can be scheduled only a daily basis.

## Code

`function.tf` contains the code to launch the Cloud Functions for the bucket replication.  The template first creates a GCS bucket for the function source code zip-file, creates a zip-file with the golang source code and stores it to the bucket.

GCP Cloud Functions is created for each bucket to be replicated.  All the functions use the same source code, source bucket is defined by the resource that triggers the function and destination bucket is defined as `DEST_BUCKET` environment variable.

Cloud Functions are given `roles/storage.objectViewer` access to the source buckets and `roles/storage.objectCreator` for the 
destination buckets.

## Demo

`demo.auto.tfvars` defines variables to configure the environment.  `gcs_buckets` is a map(string) that defines each source (value) and destination (key) bucket.  This enables the possibility to use the same code to replicate as many buckets as necessary.

GCP environment is defined with `gcp_project_id` and `gcp_region`.  As Cloud Functions is not available on all regions, it has it's own `gcp_function_region` with default to `europe-west1`.

`gcf_source_bucket` defines the bucket name for the Cloud Function source code.  `gcp_source_zip_name` defines the zip filename (default `gcs-bucket-backup.zip`).

`demo_buckets.tf` will create all the source and destination buckets and `demo_objects.tf` will add a few files from this repository content to the buckets.  Obviously in production one would most likely have the buckets already created by other parts of the Terraform code and objects are coming from elsewhere.

`demo_backend.tf` contains code to try the Cloud Function with Terraform state backend.  It has two variables, `gcs_tfstate_bucket` and `gcs_tfstate_backup_bucket` that define running and backup buckets for Terraform's state.  The backup bucket is created by the code, a Cloud Function is created, and it's given IAM permissions to access the buckets.  
`gcs` backend is configured to use the GCS bucket for Terraform state.  Before using this part of the code one should create the
bucket with `gsutil` command.

