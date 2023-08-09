output "trigger_id " {
  description = "The name of the deployed function."
  value       = google_cloudbuild_trigger.trigger_main.trigger_id
}
