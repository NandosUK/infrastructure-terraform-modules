output "cloud_events_topic" {
  value = var.cloud_events ? module.wiz_gcp_cloud_events[0].cloud_events_topic : ""
}

output "cloud_events_subscription_id" {
  value = var.cloud_events ? module.wiz_gcp_cloud_events[0].cloud_events_subscription_id : ""
}
