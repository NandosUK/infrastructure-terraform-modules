data "google_project" "current" {
  project_id = var.project_id
}

locals {
  job_name = "${var.name}-job"
}

resource "google_cloud_run_v2_job" "default" {
  name     = local.job_name
  location = var.project_region

  template {
    template {
      timeout         = var.timeout
      max_retries     = var.max_retries
      service_account = var.cloud_run_service_account
      containers {
        image = var.image

        resources {
          limits = {
            cpu    = var.cpu_limit
            memory = var.memory_limit
          }
        }

        # Conditional environment variables
        dynamic "env" {
          for_each = var.env_vars
          content {
            name  = env.key
            value = env.value
          }
        }
        dynamic "env" {
          for_each = length(var.secrets) > 0 ? tomap({ for s in var.secrets : s => s }) : {}
          content {
            name = env.key
            value_source {
              secret_key_ref {
                secret  = "projects/${var.project_id}/secrets/${env.key}"
                version = "latest"
              }
            }
          }
        }
      }

    }
  }

  lifecycle {
    ignore_changes = [
      launch_stage,
      template[0].template[0].containers[0].image,
    ]
  }
}

resource "google_project_iam_member" "sa_run_invoke" {
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"
  member  = "serviceAccount:${var.cloud_run_service_account}"
}

# Cloud Build trigger configuration
module "trigger_provision" {
  count           = var.create_trigger == true ? 1 : 0
  source          = "../cloud-cloudbuild-trigger"
  name            = "service-${var.name}-job-provision"
  repository_name = var.repository_name
  location        = var.location
  description     = "Provision ${var.name} Job (CI/CD)"
  filename        = "${var.service_path}/cloudbuild.yaml"
  include         = concat(["${var.service_path}/**"], var.dependencies)
  exclude         = ["${var.service_path}/functions/**"]
  environment     = var.environment
  project_id      = var.project_id

  trigger_service_account = var.trigger_service_account

  # Substitution variables for Cloud Build Trigger
  substitutions = merge({
    _STAGE                    = "provision"
    _BUILD_ENV                = var.environment
    _SERVICE_NAME             = var.name
    _DOCKER_ARTIFACT_REGISTRY = var.artifact_repository
    _SERVICE_PATH             = var.service_path
    _LOCATION                 = var.project_region
    _SERVICE_ACCOUNT          = var.cloud_run_service_account
    _JOB_NAME                 = local.job_name
    },
    var.trigger_substitutions
  )
}

module "cloud_run_alerts" {
  source                = "../cloud-alerts"
  project_id            = var.project_id
  service_name          = local.job_name
  enabled               = var.alert_config.enabled
  threshold_value       = var.alert_config.threshold_value
  duration              = var.alert_config.duration
  alignment_period      = var.alert_config.alignment_period
  auto_close            = var.alert_config.auto_close
  notification_channels = var.alert_config.notification_channels
}

resource "google_cloud_scheduler_job" "scheduler_job" {
  count            = var.enable_scheduler ? 1 : 0
  provider         = google-beta
  name             = "${local.job_name}-scheduler"
  description      = "Scheduled job for triggering Cloud Run job: ${local.job_name}"
  schedule         = var.schedule
  attempt_deadline = var.attempt_deadline
  region           = var.project_region
  project          = var.project_id

  retry_config {
    retry_count = var.retry_count
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.project_region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${data.google_project.current.number}/jobs/${local.job_name}:run"

    oauth_token {
      service_account_email = var.cloud_run_service_account
    }
  }
  lifecycle {
    ignore_changes = [
      paused,
    ]
  }
}
