variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "name" {
  description = "(Required) Name must be unique within a namespace, within a Cloud Run region."
  type        = string
}

variable "project_region" {
  description = "(Required) The location of the cloud run instance. eg europe-west2"
  type        = string
}

variable "domains" {
  description = "(Optional) "
  type        = list(string)
  default     = null
}

variable "cloud_run_service_account" {
  description = "(Optional) The SA that will be used as role/invoker."
  type        = string
  default     = null
}

variable "allow_public_access" {
  description = "(Optional) Enable/disable public access to the service."
  type        = bool
  default     = true
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
  description = "Environment currently running on"
  type        = string
  default     = null
}

variable "branching_strategy" {}

variable "artifact_repository" {
  description = "Artifact repository to use for this service"
  type        = string
  default     = "europe-west2-docker.pkg.dev/mgt-build-56d2ff6b/nandos-central-docker"
}


variable "create_trigger" {
  description = "Create a cloudbuild trigger for this service"
  type        = bool
  default     = true
}
