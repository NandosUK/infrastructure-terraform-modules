data "google_project" "current" {
  project_id = var.project_id
}
resource "google_cloudbuild_trigger" "trigger_main" {
  description = var.description
  tags        = var.tags
  name        = var.name
  location    = var.location
  
  github {
    owner = var.repository_owner
    name  = var.repository_name

    dynamic "push" {
      for_each = var.trigger_invocation_event == "INVOCATION_EVENT_PUSH" || var.trigger_invocation_event == "INVOCATION_EVENT_TAG" ? [1] : []
      content {
        branch       = var.branching_strategy[var.environment]["provision"]["branch"]
        tag          = var.trigger_invocation_event == "INVOCATION_EVENT_TAG" ? var.trigger_invocation_commit_tag : null
        invert_regex = var.branching_strategy[var.environment]["provision"]["invert_regex"]
      }
    }
  }
  service_account = var.trigger_service_account != "" ? "projects/${data.google_project.current.project_id}/serviceAccounts/${var.trigger_service_account}" : null

  substitutions  = var.substitutions
  filename       = var.filename
  included_files = var.include
  ignored_files  = var.exclude
  disabled       = var.disabled
}
