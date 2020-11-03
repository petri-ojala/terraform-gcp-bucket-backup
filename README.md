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

## Example run

Create GCS Bucket and initialize terraform:

```bash
$ gsutil mb -l EU gs://gcs_demo_terraform_state
Creating gs://gcs_demo_terraform_state/...
$ gsutil versioning set on gs://gcs_demo_terraform_state
Enabling versioning for gs://gcs_demo_terraform_state/...
$ terraform init

Initializing the backend...

Successfully configured the backend "gcs"! Terraform will automatically
use this backend unless the backend configuration changes.

Initializing provider plugins...
- Finding hashicorp/archive versions matching "~> 2.0.0"...
- Finding hashicorp/google versions matching "~> 3.44"...
- Installing hashicorp/google v3.46.0...
- Installed hashicorp/google v3.46.0 (signed by HashiCorp)
- Installing hashicorp/archive v2.0.0...
- Installed hashicorp/archive v2.0.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

Run terraform:

```
$ terraform apply
data.archive_file.code: Refreshing state...

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"] will be created
  + resource "google_cloudfunctions_function" "gcs_backup_function" {
      + available_memory_mb           = 128
      + description                   = "GCS Bucket backup for gcs_demo_source_bucket1"
      + entry_point                   = "GCSBucketBackup"
      + environment_variables         = {
          + "DEST_BUCKET" = "gcs_demo_dest_bucket1"
        }
      + https_trigger_url             = (known after apply)

  ...

  Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

google_storage_bucket.tfstate_backup: Creating...
google_storage_bucket.destination["gcs_demo_dest_bucket2"]: Creating...
google_storage_bucket.source["gcs_demo_dest_bucket1"]: Creating...
google_storage_bucket.source["gcs_demo_dest_bucket2"]: Creating...
google_storage_bucket.source_code: Creating...
google_storage_bucket.destination["gcs_demo_dest_bucket1"]: Creating...
google_storage_bucket.source["gcs_demo_dest_bucket2"]: Creation complete after 1s [id=gcs_demo_source_bucket2]
google_storage_bucket.tfstate_backup: Creation complete after 1s [id=gcs_demo_terraform_state_backup]
google_storage_bucket.source["gcs_demo_dest_bucket1"]: Creation complete after 1s [id=gcs_demo_source_bucket1]
google_storage_bucket.destination["gcs_demo_dest_bucket1"]: Creation complete after 1s [id=gcs_demo_dest_bucket1]
google_storage_bucket_object.demo_object_2["gcs_demo_dest_bucket2"]: Creating...
google_storage_bucket_object.demo_object_2["gcs_demo_dest_bucket1"]: Creating...
google_storage_bucket.destination["gcs_demo_dest_bucket2"]: Creation complete after 1s [id=gcs_demo_dest_bucket2]
google_storage_bucket_object.demo_object_1["gcs_demo_dest_bucket1"]: Creating...
google_storage_bucket_object.demo_object_1["gcs_demo_dest_bucket2"]: Creating...
google_storage_bucket.source_code: Creation complete after 1s [id=terraform-gcf-bucket-backup]
google_storage_bucket_object.source_code: Creating...
google_storage_bucket_object.demo_object_1["gcs_demo_dest_bucket1"]: Creation complete after 1s [id=gcs_demo_source_bucket1-demo_buckets.tf]
google_storage_bucket_object.demo_object_1["gcs_demo_dest_bucket2"]: Creation complete after 1s [id=gcs_demo_source_bucket2-demo_buckets.tf]
google_storage_bucket_object.demo_object_2["gcs_demo_dest_bucket1"]: Creation complete after 1s [id=gcs_demo_source_bucket1-demo_objects.tf]
google_storage_bucket_object.source_code: Creation complete after 1s [id=terraform-gcf-bucket-backup-gcs-bucket-backup.zip]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Creating...
google_cloudfunctions_function.gcs_tfstate_backup_function: Creating...
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Creating...
google_storage_bucket_object.demo_object_2["gcs_demo_dest_bucket2"]: Creation complete after 1s [id=gcs_demo_source_bucket2-demo_objects.tf]
google_cloudfunctions_function.gcs_tfstate_backup_function: Still creating... [10s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Still creating... [10s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [10s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [20s elapsed]
google_cloudfunctions_function.gcs_tfstate_backup_function: Still creating... [20s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Still creating... [20s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [30s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Still creating... [30s elapsed]
google_cloudfunctions_function.gcs_tfstate_backup_function: Still creating... [30s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Still creating... [40s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [40s elapsed]
google_cloudfunctions_function.gcs_tfstate_backup_function: Still creating... [40s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Still creating... [50s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [50s elapsed]
google_cloudfunctions_function.gcs_tfstate_backup_function: Still creating... [50s elapsed]
google_cloudfunctions_function.gcs_tfstate_backup_function: Still creating... [1m0s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Still creating... [1m0s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [1m0s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Still creating... [1m10s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [1m10s elapsed]
google_cloudfunctions_function.gcs_tfstate_backup_function: Still creating... [1m10s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket2"]: Creation complete after 1m13s [id=projects/pojala-gcp-playground/locations/europe-west1/functions/GCSBucketBackup-gcs_demo_source_bucket2]
google_cloudfunctions_function.gcs_tfstate_backup_function: Creation complete after 1m14s [id=projects/pojala-gcp-playground/locations/europe-west1/functions/GCSBucketBackup-tfstate]
google_storage_bucket_iam_member.function_tfstate_source: Creating...
google_storage_bucket_iam_member.function_tfstate_destination: Creating...
google_storage_bucket_iam_member.function_tfstate_destination: Creation complete after 6s [id=b/gcs_demo_terraform_state_backup/roles/storage.objectCreator/serviceaccount:pojala-gcp-playground@appspot.gserviceaccount.com]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [1m20s elapsed]
google_storage_bucket_iam_member.function_tfstate_source: Creation complete after 7s [id=b/gcs_demo_terraform_state/roles/storage.objectViewer/serviceaccount:pojala-gcp-playground@appspot.gserviceaccount.com]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [1m30s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Still creating... [1m40s elapsed]
google_cloudfunctions_function.gcs_backup_function["gcs_demo_dest_bucket1"]: Creation complete after 1m44s [id=projects/pojala-gcp-playground/locations/europe-west1/functions/GCSBucketBackup-gcs_demo_source_bucket1]
google_storage_bucket_iam_member.function_source["gcs_demo_dest_bucket2"]: Creating...
google_storage_bucket_iam_member.function_destination["gcs_demo_dest_bucket1"]: Creating...
google_storage_bucket_iam_member.function_destination["gcs_demo_dest_bucket2"]: Creating...
google_storage_bucket_iam_member.function_source["gcs_demo_dest_bucket1"]: Creating...
google_storage_bucket_iam_member.function_destination["gcs_demo_dest_bucket2"]: Creation complete after 6s [id=b/gcs_demo_dest_bucket2/roles/storage.objectCreator/serviceaccount:pojala-gcp-playground@appspot.gserviceaccount.com]
google_storage_bucket_iam_member.function_source["gcs_demo_dest_bucket1"]: Creation complete after 7s [id=b/gcs_demo_source_bucket1/roles/storage.objectViewer/serviceaccount:pojala-gcp-playground@appspot.gserviceaccount.com]
google_storage_bucket_iam_member.function_destination["gcs_demo_dest_bucket1"]: Creation complete after 7s [id=b/gcs_demo_dest_bucket1/roles/storage.objectCreator/serviceaccount:pojala-gcp-playground@appspot.gserviceaccount.com]
google_storage_bucket_iam_member.function_source["gcs_demo_dest_bucket2"]: Creation complete after 7s [id=b/gcs_demo_source_bucket2/roles/storage.objectViewer/serviceaccount:pojala-gcp-playground@appspot.gserviceaccount.com]

Apply complete! Resources: 20 added, 0 changed, 0 destroyed.
Releasing state lock. This may take a few moments...
```

And looking at the Cloud Functions logging:

```
D      GCSBucketBackup-tfstate  99tpwlvzkqsc  2020-11-03 17:23:13.991  Function execution started
       GCSBucketBackup-tfstate  99tpwlvzkqsc  2020-11-03 17:23:19.132  2020/11/03 17:23:19 object=tfstate/default.tfstate source=gcs_demo_terraform_state dest=gcs_demo_terraform_state_backup size=30729 status=OK
D      GCSBucketBackup-tfstate  99tpwlvzkqsc  2020-11-03 17:23:19.133  Function execution took 5144 ms, finished with status: 'ok'
```

Adding an object to one of the buckets:

```
$ gsutil cp go.sum gs://gcs_demo_source_bucket1/ ; sleep 60 ; gcloud beta functions logs read --region=europe-west1 --limit=3
Copying file://go.sum [Content-Type=application/octet-stream]...
/ [1 files][ 37.5 KiB/ 37.5 KiB]
Operation completed over 1 objects/37.5 KiB.
LEVEL  NAME                                     EXECUTION_ID  TIME_UTC                 LOG
D      GCSBucketBackup-gcs_demo_source_bucket1  pizh6g8skmu4  2020-11-03 17:26:18.412  Function execution started
       GCSBucketBackup-gcs_demo_source_bucket1  pizh6g8skmu4  2020-11-03 17:26:18.935  2020/11/03 17:26:18 object=go.sum source=gcs_demo_source_bucket1 dest=gcs_demo_dest_bucket1 size=38402 status=OK
D      GCSBucketBackup-gcs_demo_source_bucket1  pizh6g8skmu4  2020-11-03 17:26:18.937  Function execution took 526 ms, finished with status: 'ok'
```
