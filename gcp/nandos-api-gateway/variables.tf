variable "project_id" {
  description = "The ID of the project in which the resource belongs."
  type        = string
}

variable "project_region" {
  description = "The region for the gateway."
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

/* variable "custom_domain" {
  description = "Nandos domain for the API Gateway."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+\\.nandos\\.dev$", var.custom_domain))
    error_message = "The custom_domain must be a subdomain under nandos.dev. For example: myapi.nandos.dev."
  }
} */

variable "services" {
  type = list(object({
    name = string
    url  = string
  }))
  default = []
}
