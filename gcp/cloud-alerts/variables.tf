variable "project_id" {
  description = "The project ID to deploy to"
}

variable "service_name" {
  description = "Cloud Run service name"
}

variable "enabled" {
  description = "Whether the alert policy should be enabled"
  type        = bool
  default     = true
}

variable "threshold_value" {
  description = "Threshold value for the error rate alert"
  default     = 10.0
}

variable "duration" {
  description = "Duration for the error rate alert in seconds"
  default     = 300
}

variable "alignment_period" {
  description = "The alignment period for the time series query in seconds"
  default     = 60
}

variable "auto_close" {
  description = "The duration after which the alert will auto close in seconds"
  default     = 86400 # This sets a default value of 24 hours in seconds, adjust according to your needs
}

variable "notification_channels" {
  description = "Notification channels for the alert"
  type        = list(string)
  default     = []
}
