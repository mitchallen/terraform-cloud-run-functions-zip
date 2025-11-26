output "function_url" {
  description = "The URL of the deployed Cloud Function"
  value       = google_cloudfunctions2_function.function.url
}

output "function_name" {
  description = "The name of the Cloud Function"
  value       = google_cloudfunctions2_function.function.name
}

output "function_location" {
  description = "The location of the Cloud Function"
  value       = google_cloudfunctions2_function.function.location
}

output "bucket_name" {
  description = "The name of the GCS bucket storing the function source"
  value       = google_storage_bucket.function_bucket.name
}

output "bucket_url" {
  description = "The URL of the GCS bucket"
  value       = google_storage_bucket.function_bucket.url
}
