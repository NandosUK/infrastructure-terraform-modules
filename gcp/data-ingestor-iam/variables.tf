variable "environment" {
  type        = string
  description = "Environment that can be preview, preprod, dev or prod"

  validation {
    condition     = contains(["preview", "preprod", "prod", "dev"], var.environment)
    error_message = "The environment must be one of: preview, preprod, dev or prod."
  }
}

variable "topic" {
  type        = string
  description = "The Pub/Sub topic ID in projects/{{PROJECT_ID}}/topics/{{TOPIC_NAME}} format"
}
