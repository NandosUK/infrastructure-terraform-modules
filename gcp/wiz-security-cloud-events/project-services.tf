resource "google_project_service" "required_apis" {
  for_each = var.required_apis
  project  = local.project_id
  service  = each.value

  disable_on_destroy = false
}

resource "time_sleep" "required_apis" {
  create_duration = var.project_service_wait_time
  depends_on = [
    google_project_service.required_apis,
  ]
}
