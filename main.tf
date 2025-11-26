terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Generate a random ID for bucket name uniqueness
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Create GCS bucket for function source code
resource "google_storage_bucket" "function_bucket" {
  name                        = "${var.project_id}-${random_id.bucket_suffix.hex}-gcf-source"
  location                    = var.bucket_location
  uniform_bucket_level_access = true
  force_destroy               = var.bucket_force_destroy

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Archive the function source code
data "archive_file" "function_source" {
  type        = "zip"
  output_path = "${path.module}/function-source.zip"
  source_dir  = "${path.module}/function"
}

# Upload the zipped function code to GCS
resource "google_storage_bucket_object" "function_zip" {
  name   = "function-source-${data.archive_file.function_source.output_md5}.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = data.archive_file.function_source.output_path
}

# Deploy the Cloud Function (2nd gen)
resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  location    = var.region
  description = var.function_description

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point

    source {
      storage_source {
        bucket = google_storage_bucket.function_bucket.name
        object = google_storage_bucket_object.function_zip.name
      }
    }
  }

  service_config {
    max_instance_count    = var.max_instance_count
    min_instance_count    = var.min_instance_count
    available_memory      = var.available_memory
    timeout_seconds       = var.timeout_seconds
    environment_variables = var.environment_variables
    all_traffic_on_latest_revision = true

    service_account_email = var.service_account_email != "" ? var.service_account_email : null
  }

  labels = var.labels
}

# IAM entry to allow all users to invoke the function (optional, remove if not needed)
resource "google_cloudfunctions2_function_iam_member" "invoker" {
  count = var.allow_unauthenticated ? 1 : 0

  project        = google_cloudfunctions2_function.function.project
  location       = google_cloudfunctions2_function.function.location
  cloud_function = google_cloudfunctions2_function.function.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}
