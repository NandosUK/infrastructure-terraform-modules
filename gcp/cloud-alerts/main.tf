resource "google_monitoring_alert_policy" "error" {
  display_name = "Error Rate Alert for ${var.service_name}"
  enabled      = var.enabled
  combiner     = "OR"
  user_labels = {
    api_name = var.service_name
  }
  conditions {
    display_name = "Number of errors is above ${var.threshold_value} during ${var.duration}s"
    condition_threshold {
      aggregations {
        alignment_period   = "${var.alignment_period}s"
        per_series_aligner = "ALIGN_SUM"
      }
      trigger {
        percent = 100
      }
      duration        = "${var.duration}s"
      comparison      = "COMPARISON_GT"
      filter          = "resource.type = \"cloud_run_revision\" AND resource.labels.service_name = \"${var.service_name}\" AND metric.type = \"logging.googleapis.com/log_entry_count\" AND metric.labels.severity = \"ERROR\""
      threshold_value = var.threshold_value

    }
  }
  alert_strategy {
    auto_close = "${var.auto_close}s"
  }

  notification_channels = var.notification_channels
}
