output "https_trigger_url" {
  value = google_cloudfunctions2_function.function.service_config[0].uri
}
