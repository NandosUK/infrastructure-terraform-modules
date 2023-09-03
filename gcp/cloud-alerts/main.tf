# Error Rate Alert
resource "google_monitoring_alert_policy" "error_rate_alert" {
  project      = var.project_id
  display_name = "Error Rate Alert for ${var.service_name}"
  combiner     = "OR"

  conditions {
    display_name = "5xx Errors"

    condition_threshold {
      filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_count\" AND metric.response_code_class=\"5xx\" AND resource.service_name=\"${var.service_name}\""

      comparison      = "COMPARISON_GT"
      threshold_value = var.error_rate_threshold
      duration        = var.error_rate_duration

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_RATE"
      }
    }
  }

  notification_channels = var.alert_notification_channels
  enabled               = true
}

# High Latency Alert
resource "google_monitoring_alert_policy" "latency_alert" {
  project      = var.project_id
  display_name = "High Latency Alert for ${var.service_name}"
  combiner     = "OR"

  conditions {
    display_name = "High Latency"

    condition_threshold {
      filter = "resource.type=\"cloud_run_revision\" AND metric.type=\"run.googleapis.com/request_latencies\" AND resource.service_name=\"${var.service_name}\""

      comparison      = "COMPARISON_GT"
      threshold_value = var.latency_threshold
      duration        = var.latency_duration

      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_PERCENTILE_95"
      }
    }
  }

  notification_channels = var.alert_notification_channels
  enabled               = true
}
