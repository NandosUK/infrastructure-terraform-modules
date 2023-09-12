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

variable "domain_host" {
  description = "The host name for the domain or subdomain where this service is exposed. If empty, the systems use api.nandos.dev. You can find available domains on https://github.com/NandosUK/infrastructure/blob/master/gcp/mgt-dns/environment/inputs-for-dns.auto.tfvars"
  type        = string

  default = "api.nandos.dev"
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

variable "allow_public_access" {
  description = "(Optional) Enable/disable public access to the service's original run url."
  type        = bool
  default     = false
}

variable "sql_connection" {
  description = "(Optional) Connection to sql database"
  type        = string
  default     = null
}

variable "sharedVpcConnector" {
  description = "(Optional) Shared VPC connection string to access Nando's internal network"
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

variable "min_scale" {
  description = "Minimum number of instances for autoscaling"
  default     = 1
}

variable "max_scale" {
  description = "Maximum number of instances for autoscaling"
  default     = 100
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



# Corresponding variables for startup probe and liveness probe
variable "startup_probe_initial_delay" {
  description = "Initial delay seconds for the startup probe"
  default     = 0
}

variable "startup_probe_timeout" {
  description = "Timeout seconds for the startup probe"
  default     = 1
}

variable "startup_probe_period" {
  description = "Period seconds for the startup probe"
  default     = 3
}

variable "startup_probe_failure_threshold" {
  description = "Failure threshold for the startup probe"
  default     = 1
}

variable "startup_probe_port" {
  description = "Port for the startup probe"
  default     = 8080
}

variable "liveness_probe_path" {
  description = "Path for the liveness probe"
  default     = "/"
}
variable "cpu_limit" {
  description = "CPU limit for the Cloud Run container"
  type        = string
  default     = "1000m" # Default to 1000 milliCPU
}

variable "memory_limit" {
  description = "Memory limit for the Cloud Run container"
  type        = string
  default     = "512Mi" # Default to 512 MiB
}


variable "service_path" {
  description = "Location for the main code and where the cloudbuild.yaml exists, for example /services/myapi"
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

variable "cloud_armor" {
  description = "Configuration for Google Cloud Armor integration"
  type = object({
    enabled         = bool
    rules_file_path = string
  })
  default = {
    enabled         = false
    rules_file_path = ""
  }
}

variable "eventarc_triggers" {
  description = "Configuration for Eventarc triggers"
  type = list(object({
    event_data_content_type = string
    api_path                = string
    matching_criteria = list(object({
      attribute = string
      value     = string
      operator  = optional(string)
    }))
  }))
  default = []
}
