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
  description = "The endpoint to push messages to could be a cloud run, cloud function or any other http endpoint"
}
variable "audience" {
  type        = string
  description = "The audience to be used for the subscription push endpoint, usually the same as the push endpoint"
}
