output "https_trigger_url" {
  value = google_cloudfunctions2_function.function.service_config[0].uri
}

output "runtime" {
  value       = local.runtime
  description = "The runtime Terraform owns for this function. Pass to a cloudbuild trigger as _RUNTIME so deploys re-assert it."
}

output "source_archive_path" {
  value       = local.source_archive_path
  description = "Local path of the placeholder archive uploaded to bucket_functions: function_source_archive_path if set, otherwise the archive vendored with this module."
}
