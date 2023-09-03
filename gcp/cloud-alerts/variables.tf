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

# For 4xx Error Rate
variable "client_error_rate_threshold" {
  description = "Threshold for 4xx client error rate"
  type        = number
  default     = 50 # This sets a default value, adjust according to your needs
}

variable "client_error_rate_duration" {
  description = "Time window for 4xx client error rate"
  type        = string
  default     = "300s" # This sets a default value of 5 minutes, adjust according to your needs
}

# For Traffic Volume
variable "traffic_volume_threshold" {
  description = "Threshold for traffic volume"
  type        = number
  default     = 1000 # This sets a default value, adjust according to your needs
}

variable "traffic_volume_duration" {
  description = "Time window for traffic volume"
  type        = string
  default     = "300s" # This sets a default value of 5 minutes, adjust according to your needs
}

# For CPU Utilization
variable "cpu_utilization_threshold" {
  description = "Threshold for CPU utilization"
  type        = number
  default     = 90 # This sets a default value of 90%, adjust according to your needs
}

variable "cpu_utilization_duration" {
  description = "Time window for CPU utilization"
  type        = string
  default     = "300s" # This sets a default value of 5 minutes, adjust according to your needs
}
