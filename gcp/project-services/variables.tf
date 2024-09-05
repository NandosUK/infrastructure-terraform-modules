variable "activate_services" {
  description = "A list of services to activate"
  type        = list(string)
}

variable "project_id" {
  description = "The project ID to activate the services in."
  type        = string
}

variable "timeouts_config" {
  description = "Configuration for timeout"
  type = object({
    create = string
    read   = string
    update = string
    delete = string
  })
  default = {
    create = "20m"
    read   = "10m"
    update = "20m"
    delete = "20m"
  }
}

variable "disable_dependent_services" {
  description = "Determines if services that are enabled and which depend on this service should also be disabled when this service is destroyed."
  default     = false
  type        = bool
}
