data "google_project" "current" {
  project_id = var.project_id
}
resource "google_cloudbuild_trigger" "trigger_main" {
  description = var.description
  tags        = var.tags
  name        = var.name
  location    = var.location
  dynamic "github" {
    for_each = var.repository == null ? [1] : []
    content {
      owner = var.repository_owner
      name  = var.repository_name
      push {
        branch       = local.branching_strategy[var.environment]["provision"]["branch"]
        invert_regex = local.branching_strategy[var.environment]["provision"]["invert_regex"]
      }
    }
  }

  dynamic "repository_event_config" {
    for_each = var.repository != null ? [1] : []
    content {
      repository = var.repository
      push {
        branch       = local.branching_strategy[var.environment]["provision"]["branch"]
        invert_regex = local.branching_strategy[var.environment]["provision"]["invert_regex"]
      }
    }
  }

  service_account = var.trigger_service_account != "" ? "projects/${data.google_project.current.project_id}/serviceAccounts/${var.trigger_service_account}" : null

  substitutions  = var.substitutions
  filename       = var.filename
  included_files = var.include
  ignored_files  = var.exclude
  disabled       = var.disabled
  
  approval_config {
    approval_required = var.approval_required
  }
}

locals {
  branching_strategy = coalesce(var.branching_strategy, {
    dev = {
      validate = {
        branch       = "^NOT_USED_PREVIEW$"
        invert_regex = false
      }
      provision = {
        branch       = ".*"
        invert_regex = false
      }
    },
    preview = {
      validate = {
        branch       = "^NOT_USED_PREVIEW$"
        invert_regex = false
      }
      provision = {
        branch       = ".*"
        invert_regex = false
      }
    },
    preprod = {
      validate = {
        branch       = "^main$|^preprod$|^release/(.*)$"
        invert_regex = true
      }
      provision = {
        branch       = "^main$|^preprod$|^release/(.*)$"
        invert_regex = false
      }
    },
    prod = {
      validate = {
        branch       = "^main$"
        invert_regex = true
      }
      provision = {
        branch       = "^main$"
        invert_regex = false
      }
    }
  })
}
