output "cloud_events_topic" {
  value = google_pubsub_topic.wiz_audit_logs.id
}

output "cloud_events_subscription_id" {
  value = google_pubsub_subscription.wiz_audit_logs.name
}
