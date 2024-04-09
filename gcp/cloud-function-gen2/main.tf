data "google_project" "current" {
  project_id = var.project_id
}

locals {
  default_substitution_vars = {
    _STAGE         = "provision",
    _BUILD_ENV     = var.environment,
    _FUNCTION_NAME = var.function_name,
    _FUNCTION_PATH = var.function_path == "" ? "services/${var.service_name}/functions/${var.function_name}" : var.function_path
    _LOCATION      = var.region
  }
  default_environment_variables = {}
  service_account               = var.service_account_email != "" ? var.service_account_email : "${data.google_project.current.project_id}@appspot.gserviceaccount.com"

  // Default values for each cloud function language.
  // These are chosen by the 'function_type' variable.
  language_config = {
    node = {
      source_archive_object_name   = "node-default.zip"
      source_archive_object_source = "../../utils/default-node-function/default.zip"
      default_entry_point          = "helloWorld"
      default_runtime              = "nodejs16"
    }
    go = {
      source_archive_object_name   = "go-default.zip"
      source_archive_object_source = "../../utils/default-go-function/default.zip"
      default_entry_point          = "Entrypoint"
      default_runtime              = "go116"
    }
  }[var.function_type]

  is_generic_event_type = var.event_type != "PUBSUB" && var.event_type != "STORAGE"
}

/******************************************
	Cloud Storage Object
 *****************************************/

resource "google_storage_bucket_object" "cloud_functions_bucket_archive" {
  name   = var.function_source_archive_object != "" ? var.function_source_archive_object : local.language_config.source_archive_object_name
  bucket = var.bucket_functions
  source = local.language_config.source_archive_object_source
}

/******************************************
	Default Function
  Will be replaced by the one deployed via cloudbuild.yaml (ignore_changes = all)
 *****************************************/

resource "google_cloudfunctions2_function" "function" {
  name        = var.function_name
  description = var.function_description
  location    = var.region

  service_config {
    max_instance_count    = var.max_instance_count
    min_instance_count    = var.min_instance_count
    available_memory      = var.available_memory_mb
    timeout_seconds       = var.timeout_seconds
    available_cpu         = var.cpu_limit
    service_account_email = local.service_account
    environment_variables = merge(local.default_environment_variables, var.environment_variables)
    dynamic "secret_environment_variables" {
      for_each = var.secret_keys
      content {
        key        = secret_environment_variables.value
        project_id = var.project_id

        secret  = secret_environment_variables.value
        version = "latest"
      }
    }
  }

  dynamic "event_trigger" {
    for_each = var.event_type == "PUBSUB" ? [var.event_trigger] : []
    content {
      trigger_region        = var.region
      event_type            = event_trigger.value["event_type"]
      pubsub_topic          = event_trigger.value["pubsub_topic"]
      retry_policy          = event_trigger.value["retry_policy"]
      service_account_email = event_trigger.value["service_account_email"]
    }
  }

  dynamic "event_trigger" {
    for_each = var.event_type == "STORAGE" ? [var.event_trigger] : []
    content {
      trigger_region        = var.region
      event_type            = event_trigger.value["event_type"]
      retry_policy          = event_trigger.value["retry_policy"]
      service_account_email = event_trigger.value["service_account_email"]
      event_filters {
        attribute = "bucket"
        value     = event_trigger.value["bucket_name"]
      }
    }
  }

  dynamic "event_trigger" {
    for_each = local.is_generic_event_type ? [var.event_trigger] : []
    content {
      trigger_region        = var.region
      event_type            = event_trigger.value["event_type"]
      retry_policy          = event_trigger.value["retry_policy"]
      service_account_email = event_trigger.value["service_account_email"]
      dynamic "event_filters" {
        for_each = event_trigger.value["event_filters"]

        content {
          attribute       = event_filters.value["attribute"]
          value           = event_filters.value["value"]
          operator        = event_filters.value["operator"]
        }
      }
    }
  }

  build_config {
    runtime     = var.function_runtime != "" ? var.function_runtime : local.language_config.default_runtime
    entry_point = var.function_entry_point != "" ? var.function_entry_point : local.language_config.default_entry_point
    source {
      storage_source {
        bucket = var.bucket_functions
        object = google_storage_bucket_object.cloud_functions_bucket_archive.name
      }
    }
  }

  lifecycle {
    ignore_changes = [build_config]
  }
}


resource "google_cloud_scheduler_job" "job" {
  count            = var.event_type == "SCHEDULER" ? 1 : 0
  name             = var.function_name
  paused           = var.schedule.paused
  description      = "Schedule ${var.function_name}"
  schedule         = var.schedule.cron
  time_zone        = var.schedule.timezone
  attempt_deadline = var.schedule.attempt_deadline

  http_target {
    http_method = var.schedule.http_method
    uri         = google_cloudfunctions2_function.function.service_config[0].uri

    oidc_token {
      service_account_email = local.service_account
    }
    body    = var.schedule.http_method == "POST" || var.schedule.http_method == "PUT" ? base64encode(var.schedule.http_body) : null
    headers = var.schedule.http_headers
  }
  retry_config {
    retry_count = 1
  }
  lifecycle {
    ignore_changes = [paused, http_target["body"], schedule]
  }
}


# IAM entry for all users to invoke the function
resource "google_cloudfunctions_function_iam_member" "invoker" {
  count          = var.public ? 1 : 0
  project        = google_cloudfunctions2_function.function.project
  cloud_function = google_cloudfunctions2_function.function.name

  role   = "roles/cloudfunctions.invoker"
  member = "allUsers"
}


/******************************************
	Triggers
 *****************************************/
module "trigger_provision" {
  name            = "function-${var.function_name}-provision"
  description     = "Provision ${var.function_name} Service (CI/CD)"
  source          = "../cloud-cloudbuild-trigger"
  location        = var.location
  filename        = var.function_path == "" ? "services/${var.service_name}/functions/${var.function_name}/cloudbuild.yaml" : "${var.function_path}/cloudbuild.yaml"
  include         = var.function_path == "" ? ["services/${var.service_name}/functions/${var.function_name}/**"] : ["${var.function_path}/**"]
  tags            = ["function"]
  substitutions   = merge(local.default_substitution_vars, var.trigger_substitutions)
  environment     = var.environment
  repository_name = var.repository_name
}

/******************************************
	Alerts definition
 *****************************************/

module "cloud_function_alerts" {
  source                = "../cloud-alerts"
  project_id            = var.project_id
  service_name          = var.function_name
  enabled               = var.alert_config.enabled
  threshold_value       = var.alert_config.threshold_value
  duration              = var.alert_config.duration
  alignment_period      = var.alert_config.alignment_period
  auto_close            = var.alert_config.auto_close
  notification_channels = var.alert_config.notification_channels
}
