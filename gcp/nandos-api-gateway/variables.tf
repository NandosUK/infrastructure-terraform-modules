variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "project_region" {
  description = "The region for the gateway."
  type        = string
}

variable "cloud_run_url" {
  description = "The URL for the Cloud Run service."
  type        = string
}

variable "api_name" {
  description = "The name for the API Gateway API."
  type        = string

  validation {
    condition     = can(regex("^[a-z-]+$", var.api_name))
    error_message = "The API name must consist only of lowercase letters and dashes."
  }

  validation {
    condition     = length(var.api_name) > 0
    error_message = "The API name must not be empty."
  }
}

variable "openapi_spec_file_path" {
  description = "The path to the OpenAPI spec file."
  type        = string
}
