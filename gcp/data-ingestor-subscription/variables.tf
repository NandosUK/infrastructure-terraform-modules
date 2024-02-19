variable "subscription_type" {
  type        = string
  description = "The type of the subscription to create, can be 'push' or 'pull'."
  default     = "push"
}

variable "name" {
  type        = string
  description = "The name of the subscription, should be the same as your service"
}
variable "topic_name" {
  type        = string
  description = "Make sure this topic exists"
}
variable "environment" {
  type        = string
  description = "The environment that can be preview, preprod, dev or prod"
  validation {
    condition     = contains(["preview", "preprod", "prod", "dev"], var.environment)
    error_message = "The environment must be one of: preview, preprod, dev or prod."
  }
}
variable "service_account_email" {
  type        = string
  description = "The service account email to be used for the subscription"
}
variable "push_endpoint" {
  type        = string
  description = "The endpoint to push messages to could be a cloud run, cloud function, or any other HTTP endpoint"
  default     = null
}

variable "audience" {
  type        = string
  description = "The audience to be used for the subscription push endpoint, usually the same as the push endpoint"
  default     = null
}

variable "message_retention_duration" {
  description = "How long to retain unacknowledged messages in the subscription's backlog, specified as a duration in seconds."
  type        = string
  default     = "1200s" # Default to 20 minutes
}

variable "retain_acked_messages" {
  description = "Indicates whether to retain acknowledged messages."
  type        = bool
  default     = true
}

variable "ack_deadline_seconds" {
  description = "The maximum time after a subscriber receives a message before the subscriber should acknowledge the message."
  type        = number
  default     = 20
}

variable "expiration_ttl" {
  description = "Specifies the \"time-to-live\" duration for an associated resource. The resource expires if it is not active for a period of ttl."
  type        = string
  default     = "300000.5s" # Default to about 3.5 days
}

variable "minimum_backoff" {
  description = "The minimum delay between consecutive deliveries of a given message."
  type        = string
  default     = "10s"
}

variable "enable_message_ordering" {
  description = "If true, messages published with the same orderingKey in PubsubMessage will be delivered to the subscribers in the order in which they are received by the Pub/Sub system."
  type        = bool
  default     = false
}
