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
    // Deploys re-assert Terraform's runtime instead of competing with it. Call
    // sites can still override via trigger_substitutions.
    _RUNTIME = local.runtime
  }
  default_environment_variables = {}

  // Built once so both branches of the filename ternary below stay in sync. With
  // the default suffix of "" this is exactly "cloudbuild.yaml".
  cloudbuild_yaml = "cloudbuild${var.cloudbuild_yaml_suffix}.yaml"

  service_account = var.service_account_email != "" ? var.service_account_email : "${data.google_project.current.project_id}@appspot.gserviceaccount.com"

  // Default values for each cloud function language.
  // These are chosen by the 'function_type' variable.
  language_config = {
    node = {
      source_archive_object_name   = "node-default.zip"
      source_archive_object_source = "../../utils/default-node-function/default.zip"
      default_entry_point          = "helloWorld"
      default_runtime              = var.node_version
    }
    go = {
      source_archive_object_name   = "go-default.zip"
      source_archive_object_source = "../../utils/default-go-function/default.zip"
      default_entry_point          = "Entrypoint"
      default_runtime              = var.go_version
    }
  }[var.function_type]

  // The runtime Terraform owns. Exposed as an output and as the _RUNTIME
  // substitution so a bump here applies everywhere instead of per call site.
  runtime = var.function_runtime != "" ? var.function_runtime : local.language_config.default_runtime

  // The two secret inputs normalised into one shape. secret_keys is the
  // shorthand for "env var name == secret name, in this project, at latest";
  // secret_environment_variables spells out the cases where that does not hold.
  // Keyed by env var name so an explicit entry wins over a shorthand one.
  secret_environment_variables = values(merge(
    {
      for key in var.secret_keys : key => {
        key        = key
        secret     = key
        version    = "latest"
        project_id = var.project_id
      }
    },
    {
      for secret in var.secret_environment_variables : secret.key => {
        key        = secret.key
        secret     = coalesce(secret.secret, secret.key)
        version    = secret.version
        project_id = coalesce(secret.project_id, var.project_id)
      }
    },
  ))
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
  labels      = var.labels

  service_config {
    max_instance_count    = var.max_instance_count
    min_instance_count    = var.min_instance_count
    available_memory      = var.available_memory_mb
    timeout_seconds       = var.timeout_seconds
    available_cpu         = var.cpu_limit
    service_account_email = local.service_account
    environment_variables = merge(local.default_environment_variables, var.environment_variables)

    max_instance_request_concurrency = var.max_instance_request_concurrency
    ingress_settings                 = var.ingress_settings
    vpc_connector                    = var.vpc_connector
    vpc_connector_egress_settings    = var.vpc_connector_egress_settings

    dynamic "secret_environment_variables" {
      for_each = { for secret in local.secret_environment_variables : secret.key => secret }
      content {
        key        = secret_environment_variables.value.key
        secret     = secret_environment_variables.value.secret
        version    = secret_environment_variables.value.version
        project_id = secret_environment_variables.value.project_id
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
    for_each = var.event_type == "EVENTARC" ? [var.event_trigger] : []
    content {
      trigger_region        = var.region
      event_type            = event_trigger.value["event_type"]
      retry_policy          = event_trigger.value["retry_policy"]
      service_account_email = event_trigger.value["service_account_email"]
      dynamic "event_filters" {
        for_each = event_trigger.value["event_filters"]

        content {
          attribute = event_filters.value["attribute"]
          value     = event_filters.value["value"]
          operator  = event_filters.value["operator"]
        }
      }
    }
  }

  build_config {
    runtime     = local.runtime
    entry_point = var.function_entry_point != "" ? var.function_entry_point : local.language_config.default_entry_point
    source {
      storage_source {
        bucket = var.bucket_functions
        object = google_storage_bucket_object.cloud_functions_bucket_archive.name
      }
    }
  }

  lifecycle {
    precondition {
      condition = var.event_trigger == null || contains(
        ["PUBSUB", "STORAGE", "EVENTARC"], coalesce(var.event_type, "")
      )
      error_message = <<-EOT
        event_trigger is set but event_type is ${coalesce(var.event_type, "null")}.
        The trigger blocks are selected by event_type, so the function would be
        created with no trigger at all. Set event_type to PUBSUB, STORAGE or
        EVENTARC.
      EOT
    }

    // Everything the cloudbuild deploy owns, but *not* runtime -- that stays
    // reconciled so a bump applies on apply rather than on each function's next
    // deploy. build_config is separate from service_config, so un-ignoring the
    // runtime touches nothing else.
    ignore_changes = [
      build_config[0].source,
      build_config[0].entry_point,
      build_config[0].docker_repository,
      build_config[0].service_account,
      build_config[0].environment_variables,
      build_config[0].worker_pool,
      build_config[0].automatic_update_policy,
      build_config[0].on_deploy_update_policy,
    ]
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


# IAM entry for all users to invoke the function.
# Gen 2 functions are fronted by Cloud Run, so invocation is authorised with
# roles/run.invoker on the underlying service -- not the gen 1
# roles/cloudfunctions.invoker.
resource "google_cloud_run_service_iam_member" "invoker" {
  count    = var.public ? 1 : 0
  project  = google_cloudfunctions2_function.function.project
  location = google_cloudfunctions2_function.function.location
  service  = basename(google_cloudfunctions2_function.function.service_config[0].service)

  role   = "roles/run.invoker"
  member = "allUsers"
}


/******************************************
	Triggers
 *****************************************/
module "trigger_provision" {
  name                    = "function-${var.function_name}-provision"
  description             = "Provision ${var.function_name} Service (CI/CD)"
  source                  = "../cloud-cloudbuild-trigger"
  approval_required       = var.approval_required
  trigger_service_account = var.trigger_service_account
  location                = var.location
  filename                = var.function_path == "" ? "services/${var.service_name}/functions/${var.function_name}/${local.cloudbuild_yaml}" : "${var.function_path}/${local.cloudbuild_yaml}"
  include                 = var.function_path == "" ? ["services/${var.service_name}/functions/${var.function_name}/**"] : ["${var.function_path}/**"]
  tags                    = ["function"]
  substitutions           = merge(local.default_substitution_vars, var.trigger_substitutions)
  environment             = var.environment
  repository_name         = var.repository_name
  project_id              = var.project_id
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
  resource_type         = "cloud_run_revision"
}


/******************************************
	Guards against silently-ignored inputs
 *****************************************/

// Warnings rather than preconditions: existing callers pass these and their
// applies must keep working. The point is to make the alert routing visible at
// plan time instead of discovering it when an incident fails to page.
check "alert_notification_channels_are_wired" {
  assert {
    condition     = length(var.notification_channels) == 0 || length(var.alert_config.notification_channels) > 0
    error_message = <<-EOT
      ${var.function_name}: notification_channels is set but unused, and
      alert_config.notification_channels is empty, so this function's alert
      policy will not notify anyone. Move the channels into alert_config.
    EOT
  }
}

// The literals below mirror the defaults of var.threshold_value and
// var.alert_config.threshold_value -- Terraform cannot reference a variable's
// own default, so they must be kept in sync by hand if either default changes.
check "alert_threshold_is_wired" {
  assert {
    condition     = var.threshold_value == 60 || var.alert_config.threshold_value != 10.0
    error_message = <<-EOT
      ${var.function_name}: threshold_value is set but unused, and alert_config
      is at its default threshold of 10. Move the threshold into alert_config.
    EOT
  }
}
