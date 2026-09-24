variable "bucket_functions" {}
variable "function_name" {}
variable "function_description" {}

// Overrides the default path of services/{service name}/functions/{function name}
variable "function_path" {
  description = "Path to the function, if not provided, it will be generated based on the function name"
  default     = ""
}
variable "service_name" {
  description = "Name of the service wrapping this function (you must have functions folder in it)"
}

variable "branching_strategy" {
  default     = ""
  description = <<-EOT
    Unused. Retained for backwards compatibility with existing callers.
    The cloud-cloudbuild-trigger submodule derives push branches from its own
    per-environment defaults keyed off var.environment, so nothing passed here
    has any effect.
  EOT
}

variable "trigger_substitutions" {
  description = "Substitution variable for the trigger, think about Buckets names, pubsub names, service accounts, etc. Anything dynamic you will need to deploy this function (via Yaml file)"

}
variable "environment_variables" {
  description = "Environment variables that shall be available during function execution."
  default     = {}
}

variable "region" {
  default = "europe-west2"
}

variable "environment" {}

variable "public" {
  type    = bool
  default = false
}

variable "timeout_seconds" {
  type    = number
  default = 60
}

variable "max_instance_count" {
  type    = number
  default = 1
}

variable "min_instance_count" {
  type    = number
  default = 1
}

variable "service_account_email" {
  default = ""
}

variable "available_memory_mb" {
  type    = string
  default = "256M"
}

variable "cpu_limit" {
  default = null
}

variable "notification_channels" {
  default     = []
  description = <<-EOT
    Unused. Retained for backwards compatibility with existing callers.
    Alert routing is read from var.alert_config.notification_channels instead.
    This is deliberately not wired up as a fallback: callers that set this but
    leave alert_config unset currently get non-notifying alert policies, and
    silently turning their alerts on is not a backwards-compatible change.
  EOT
}

variable "function_runtime" {
  default = ""
}

variable "function_entry_point" {
  default = ""
}

variable "function_source_archive_object" {
  default = ""
}

variable "function_type" {}

variable "cloudbuild_yaml_suffix" {
  type        = string
  default     = ""
  description = <<-EOT
    Suffix inserted into the Cloud Build config filename, as
    "cloudbuild<suffix>.yaml". Defaults to "" for "cloudbuild.yaml".
    Use when several functions share one source directory and each needs its own
    build config, e.g. "-collector" and "-pubsub" for a service that for_each-es
    over {collector, pubsub} against cloudbuild-collector.yaml and
    cloudbuild-pubsub.yaml.
  EOT
}

variable "threshold_value" {
  default = 60
}

variable "event_type" {
  default = null
}

variable "event_trigger" {
  description = "List of event triggers"
  type = object({
    trigger_region        = optional(string)
    event_type            = string
    retry_policy          = string
    service_account_email = string
    bucket_name           = optional(string)
    pubsub_topic          = optional(string)
    event_filters = optional(list(object({
      attribute = string
      value     = string
      operator  = optional(string)
    })))
  })
  default = null
}

variable "schedule" {
  type = object({
    cron             = string
    timezone         = string
    attempt_deadline = string
    paused           = bool
    http_method      = string
    http_body        = any
    http_headers     = map(string)
  })
  default = {
    cron             = "0 0 5 31 2 ?"
    timezone         = "Europe/London"
    attempt_deadline = "320s"
    paused           = true
    http_method      = "GET"
    http_body        = null
    http_headers     = {}
  }
}

variable "secret_keys" {
  description = <<-EOT
    Secrets mounted as environment variables where the environment variable name
    and the Secret Manager secret name are identical, in var.project_id, at
    version "latest". Use var.secret_environment_variables when any of those
    differ; the two are merged.
  EOT
  default     = []
}

variable "http_headers" {
  type    = map(string)
  default = {}
}

variable "repository_name" {
  description = "Repo name where the service is located (in GitHub)"
  type        = string
}

variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "location" {
  description = "Cloud build trigger location. If not specified, the default location will be global."
  type        = string
  default     = null
}

variable "trigger_config" {
  description = "Configuration for the Cloud Build Trigger"
  type = object({
    name            = string
    repository_name = string
    description     = string
    filename        = string
    include         = list(string)
    exclude         = list(string)
    environment     = string
    substitutions   = map(string)
    create_trigger  = bool
  })
  default = {
    name            = "default-trigger-name"
    repository_name = "default-repo-name"
    description     = "default-description"
    filename        = "cloudbuild.yaml"
    include         = []
    exclude         = []
    environment     = null
    substitutions   = {}
    create_trigger  = true
  }
}
variable "alert_config" {
  description = "Configuration for alerts"
  type = object({
    enabled               = bool
    threshold_value       = number
    duration              = number
    alignment_period      = number
    auto_close            = number
    notification_channels = list(string)
  })
  default = {
    enabled               = true
    threshold_value       = 10.0
    duration              = 300
    alignment_period      = 60
    auto_close            = 86400
    notification_channels = []
  }
}

variable "trigger_service_account" {
  type        = string
  description = "Service account to use for the Cloud Build trigger."
  default     = ""
}
variable "node_version" {
  description = "Default Node.js runtime version for deployed functions. Latest GA on gen 2 is nodejs24 (nodejs26 is preview)."
  default     = "nodejs24"
  nullable    = false
}

variable "go_version" {
  description = "Default Go runtime version for deployed functions. Latest GA on gen 2 is go127."
  default     = "go127"
  nullable    = false
}

variable "approval_required" {
  type        = bool
  default     = false
  description = "If true, Cloud Build trigger will require manual approval before executing."
}

variable "secret_environment_variables" {
  description = <<-EOT
    Secrets mounted as environment variables, for the common case where the
    environment variable name differs from the Secret Manager secret name --
    which var.secret_keys cannot express, since it uses one string for both.

      secret_environment_variables = [
        { key = "AUTH_KEY", secret = "DISABLE_EXPIRED_JOBS_AUTH_KEY" },
        { key = "OKTA_API_KEY", secret = "PROFILE_API_OKTA_API_KEY", version = "3" },
        { key = "SHARED", secret = "SHARED", project_id = "other-project" },
      ]

    secret defaults to key, version to "latest", and project_id to
    var.project_id. Merged with var.secret_keys, which remains supported.
  EOT
  type = list(object({
    key        = string
    secret     = optional(string)
    version    = optional(string, "latest")
    project_id = optional(string)
  }))
  default = []
}

variable "max_instance_request_concurrency" {
  description = "Maximum concurrent requests per instance. Null leaves the API default in place."
  type        = number
  default     = null
}

variable "ingress_settings" {
  description = "Ingress settings for the function. Null leaves the API default (ALLOW_ALL) in place."
  type        = string
  default     = null

  validation {
    condition = var.ingress_settings == null ? true : contains(
      ["ALLOW_ALL", "ALLOW_INTERNAL_ONLY", "ALLOW_INTERNAL_AND_GCLB"],
      var.ingress_settings
    )
    error_message = "ingress_settings must be ALLOW_ALL, ALLOW_INTERNAL_ONLY or ALLOW_INTERNAL_AND_GCLB."
  }
}

variable "vpc_connector" {
  description = "Serverless VPC Access connector to route egress through. Null for no connector."
  type        = string
  default     = null
}

variable "vpc_connector_egress_settings" {
  description = "Which egress traffic uses the VPC connector. Only meaningful when vpc_connector is set."
  type        = string
  default     = null

  validation {
    condition = var.vpc_connector_egress_settings == null ? true : contains(
      ["PRIVATE_RANGES_ONLY", "ALL_TRAFFIC"],
      var.vpc_connector_egress_settings
    )
    error_message = "vpc_connector_egress_settings must be PRIVATE_RANGES_ONLY or ALL_TRAFFIC."
  }
}

variable "labels" {
  description = "Labels applied to the function."
  type        = map(string)
  default     = {}
}
