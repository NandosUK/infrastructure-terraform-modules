resource "google_cloudfunctions_function" "function" {
  name        = var.function_name
  description = var.description
  runtime     = var.runtime

  available_memory_mb   = var.available_memory_mb
  source_archive_bucket = var.source_archive_bucket
  source_archive_object = var.source_archive_object

  entry_point = var.entry_point

  trigger_http = var.trigger_http

  labels = var.labels
}
 