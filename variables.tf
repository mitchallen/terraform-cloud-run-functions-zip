variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The region where the function will be deployed"
  type        = string
  default     = "us-central1"
}

variable "bucket_location" {
  description = "The location for the GCS bucket"
  type        = string
  default     = "US"
}

variable "bucket_force_destroy" {
  description = "Whether to force destroy the bucket even if it contains objects"
  type        = bool
  default     = true
}

variable "function_name" {
  description = "The name of the Cloud Function"
  type        = string
  default     = "python-http-function"
}

variable "function_description" {
  description = "Description of the Cloud Function"
  type        = string
  default     = "Python HTTP Cloud Function deployed via Terraform"
}

variable "runtime" {
  description = "The runtime in which the function will be executed"
  type        = string
  default     = "python312"
}

variable "entry_point" {
  description = "The name of the function to execute"
  type        = string
  default     = "hello_http"
}

variable "max_instance_count" {
  description = "The maximum number of instances for the function"
  type        = number
  default     = 3
}

variable "min_instance_count" {
  description = "The minimum number of instances for the function"
  type        = number
  default     = 0
}

variable "available_memory" {
  description = "The amount of memory available for the function"
  type        = string
  default     = "256M"
}

variable "timeout_seconds" {
  description = "The function execution timeout in seconds"
  type        = number
  default     = 60
}

variable "environment_variables" {
  description = "Environment variables for the function"
  type        = map(string)
  default     = {}
}

variable "ingress_settings" {
  description = "The ingress settings for the function. Valid values: ALLOW_INTERNAL_ONLY, ALLOW_INTERNAL_AND_GCLB, or empty string for all traffic"
  type        = string
  default     = ""
}

variable "service_account_email" {
  description = "The service account email to run the function as"
  type        = string
  default     = ""
}

variable "allow_unauthenticated" {
  description = "Whether to allow unauthenticated access to the function"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to the function"
  type        = map(string)
  default = {
    deployed-by = "terraform"
  }
}
