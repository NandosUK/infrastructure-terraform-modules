variable "project_id" {
  description = "The project ID to deploy to"
}

variable "alert_notification_channels" {
  description = "Notification channels for the alert"
  type        = list(string)
  default     = []
}

variable "service_name" {
  description = "Cloud Run service name"
}


variable "error_rate_threshold" {
  description = "Threshold for the error rate alert"
  default     = 10.0
}

variable "error_rate_duration" {
  description = "Duration for the error rate alert"
  default     = "300s"
}

variable "latency_threshold" {
  description = "Threshold for the latency alert"
  default     = 1000.0
}

variable "latency_duration" {
  description = "Duration for the latency alert"
  default     = "300s"
}
