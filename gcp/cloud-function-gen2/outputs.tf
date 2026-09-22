output "https_trigger_url" {
  value = google_cloudfunctions2_function.function.service_config[0].uri
}

output "runtime" {
  value       = local.runtime
  description = "The runtime Terraform owns for this function. Pass to a cloudbuild trigger as _RUNTIME so deploys re-assert it."
}
