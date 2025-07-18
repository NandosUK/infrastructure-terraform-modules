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

variable "custom_domain" {
  description = "Override the autogenerated subdomain"
  type        = string
  default     = null
}

variable "project_region" {
  description = "(Required) The location of the cloud run instance. eg europe-west2"
  type        = string
}

variable "container_port" {
  description = "(Optional) Port number the container listens on. This must be a valid TCP port number."
  type        = number
  default     = 8080

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
variable "repository_owner" {
  description = "Repo owner where the service is located (in GitHub)"
  type        = string
  default     = "NandosUK"
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

variable "vpc_access_connector" {
  description = "(Optional) The VPC Access Connector to use for this service"
  type        = string
  default     = null
}
variable "vpc_access_egress" {
  description = "(Optional) Traffic VPC egress settings. Possible values are: ALL_TRAFFIC, PRIVATE_RANGES_ONLY"
  type        = string
  default     = null
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
# Startup probe
variable "startup_probe_initial_delay" {
  description = "Initial delay seconds for the startup probe"
  default     = 20
}

variable "startup_probe_timeout" {
  description = "Timeout seconds for the startup probe"
  default     = 5
}

variable "timeout" {
  description = "Specifies the time within which a response must be returned by services deployed to Cloud Run"
  default     = "600s"
}

variable "startup_probe_period" {
  description = "Period seconds for the startup probe"
  default     = 30
}

variable "startup_probe_failure_threshold" {
  description = "Failure threshold for the startup probe"
  default     = 3
}

variable "startup_probe_port" {
  description = "Port for the startup probe"
  default     = 8080
}

variable "startup_probe_path" {
  description = "Path for the startup probe"
  default     = null
}

# Liveness probe
variable "liveness_probe_initial_delay" {
  description = "Initial delay seconds for the liveness probe"
  default     = 0
}

variable "liveness_probe_timeout" {
  description = "Timeout seconds for the liveness probe"
  default     = 1
}

variable "liveness_probe_period" {
  description = "Period seconds for the liveness probe"
  default     = 3
}

variable "liveness_probe_failure_threshold" {
  description = "Failure threshold for the liveness probe"
  default     = 1
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

variable "trigger_substitutions" {
  description = "Substitution variables for Cloud Build Trigger"
  type        = map(string)
  default     = {}
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

variable "dependencies" {
  description = "A list of glob-format dependencies for the cloudbuild trigger"
  type        = list(string)
  default     = []
}

variable "enable_custom_domain" {
  description = "Create necessary resources to bind a custom domain to the resource"
  type        = bool
  default     = true
}

variable "create_url_map" {
  description = "Create a URL map for the load balancer. If false, the URL map must be created manually"
  type        = bool
  default     = true
}


variable "additional_backend_services" {
  description = "Additional backend services to be used in the load balancer"
  type = map(object({
    group       = string
    cloud_armor = bool
  }))
  default = {}
}

variable "path_rules" {
  description = "Custon path rules for the load balancer"
  type = list(object({
    paths        = list(string)
    service_name = string
    route_action = optional(object({
      url_rewrite = optional(object({
        path_prefix_rewrite = string
      }))
    }))
  }))
  default = null
}

variable "startup_cpu_boost" {
  description = "CPU boost for the Cloud Run container"
  type        = bool
  default     = true
}

variable "cpu_idle" {
  description = "CPU idle for the Cloud Run container"
  type        = bool
  default     = true
}

variable "enable_lb_logging" {
  description = "Enable logging for the load balancer"
  type        = bool
  default     = false
}

variable "trigger_service_account" {
  type        = string
  description = "Service account to use for the Cloud Build trigger."
  default     = ""
}

variable "ingress" {
  type        = string
  description = "Provides the ingress settings for this service."
  default     = "INGRESS_TRAFFIC_ALL"
  validation {
    condition     = contains(["INGRESS_TRAFFIC_ALL", "INGRESS_TRAFFIC_INTERNAL_ONLY", "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"], var.ingress)
    error_message = "The ingress must be one of: INGRESS_TRAFFIC_ALL, INGRESS_TRAFFIC_INTERNAL_ONLY, INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER."
  }
}

variable "deletion_protection" {
  description = "Whether Terraform will be prevented from destroying the service. Defaults to true"
  type        = bool
  default     = true
}
