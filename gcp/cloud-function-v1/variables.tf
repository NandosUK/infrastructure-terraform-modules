variable "function_name" {
  description = "The name of the cloud function."
  type        = string
}

variable "description" {
  description = "The description of the cloud function."
  type        = string
}

variable "runtime" {
  description = "The runtime in which the function will be executed."
  type        = string
}

variable "available_memory_mb" {
  description = "The amount of memory in MB available for the function."
  type        = number
  default     = 256
}

variable "source_archive_bucket" {
  description = "The GCS bucket containing the source code."
  type        = string
}

variable "source_archive_object" {
  description = "The GCS object containing the source code."
  type        = string
}

variable "entry_point" {
  description = "The entry point of the function."
  type        = string
}

variable "trigger_http" {
  description = "Boolean variable to specify an HTTP trigger."
  type        = bool
}

variable "labels" {
  description = "A set of key/value label pairs to assign to the function."
  type        = map(string)
  default     = {}
}
