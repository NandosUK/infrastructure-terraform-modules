variable "bucket_functions" {}
variable "function_name" {}
variable "function_description" {}

// Overrides the default path of services/{service name}/functions/{function name}
variable "function_path" {
  description = "Path to the function, if not provided, it will be generated based on the function name"
  default = ""
}
variable "service_name" {
  description = "Name of the service wrapping this function (you must have functions folder in it)"
}

variable "branching_strategy" {}

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

variable "notification_channels" {}

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

variable "threshold_value" {
  default = 60
}

variable "event_type" {
  default = null
}

variable "event_trigger" {
  description = "List of event triggers"
  # type = {
  #   trigger_region        = string
  #   event_type            = string
  #   retry_policy          = string
  #   service_account_email = string
  #   event_filters = list(object({
  #     attribute       = string
  #     value           = string
  #     operator        = optional(string)
  #   }))
  # }
  default     = null
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
  default = []
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
