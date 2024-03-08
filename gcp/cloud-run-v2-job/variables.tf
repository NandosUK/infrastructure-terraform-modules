variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "name" {
  description = "(Required) Name must be unique within a namespace, within a Cloud Run region. No spaces or special characters allowed."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.name))
    error_message = "The name can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "project_region" {
  description = "(Required) The location of the cloud run instance. eg europe-west2"
  type        = string
}


variable "cloud_run_service_account" {
  description = "(Optional) The SA that will be used as role/invoker."
  type        = string
  default     = null
}


variable "environment" {
  type        = string
  description = "Environment that can be preview, preprod, dev or prod"

  validation {
    condition     = contains(["preview", "preprod", "prod", "dev"], var.environment)
    error_message = "The environment must be one of: preview, preprod, dev or prod."
  }
}

variable "artifact_repository" {
  description = "Artifact repository to use for this service"
  type        = string
  default     = "europe-west2-docker.pkg.dev/mgt-build-56d2ff6b/nandos-central-docker"
}

variable "repository_name" {
  description = "Repo name where the service is located (in GitHub)"
  type        = string
}

variable "create_trigger" {
  description = "Create a cloudbuild trigger for this service"
  type        = bool
  default     = true
}

variable "max_retries" {
  description = "Maximum number of retries for failed jobs"
  default     = 3
}

# Declare new variables
variable "env_vars" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}
variable "secrets" {
  description = "List of secret names from Secret Manager"
  type        = list(string)
  default     = []
}

variable "timeout" {
  description = "Max allowed time duration the Task may be active before the system will actively try to mark it failed and kill associated containers."
  type        = string
  default     = "1800s" # Default to 30 min
}

variable "memory_limit" {
  description = "Memory limit for the Cloud Run container"
  type        = string
  default     = "4096Mi" # Default to 4Gi memory
}

variable "cpu_limit" {
  description = "CPU limit for the Cloud Run container"
  type        = string
  default     = "2000m" # Default to 1000 milliCPU
}

variable "service_path" {
  description = "Location for the main code and where the cloudbuild.yaml exists, for example /services/myapi"
  type        = string
}

variable "location" {
  description = "Cloud build trigger location. If not specified, the default location will be global."
  type        = string
  default     = null
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

variable "trigger_substitutions" {
  description = "Substitution variables for Cloud Build Trigger"
  type        = map(string)
  default     = {}
}

variable "dependencies" {
  description = "A list of glob-format dependencies for the cloudbuild trigger"
  type        = list(string)
  default     = []
}
