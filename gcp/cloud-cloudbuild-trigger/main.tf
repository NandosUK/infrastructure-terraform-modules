resource "google_cloudbuild_trigger" "trigger_main" {
  description = var.description
  tags        = var.tags
  name        = var.name
  location    = var.location
  github {
    owner = var.repository_owner
    name  = var.repository_name
    push {
      branch       = var.branching_strategy[var.environment]["provision"]["branch"]
      invert_regex = var.branching_strategy[var.environment]["provision"]["invert_regex"]
    }
  }
  substitutions  = var.substitutions
  filename       = var.filename
  included_files = var.include
  ignored_files  = var.exclude
  disabled       = var.disabled
}
