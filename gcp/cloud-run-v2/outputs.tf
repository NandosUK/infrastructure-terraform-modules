output "service_url" {
  description = "URL of Cloud Run service"
  value       = google_cloud_run_v2_service.default.uri
}

output "service_name" {
  description = "Name of Cloud Run service"
  value       = google_cloud_run_v2_service.default.name
}

output "external_ip" {
  description = "value"
  value       = length(module.lb-http) > 0 ? module.lb-http[0].external_ip : null
}

output "cloud_armor_policy_self_link" {
  description = "Self link of the Cloud Armor security policy, or null when cloud_armor is disabled. Attach it to your own backend service when using cloud_armor.external_attachment."
  value       = length(google_compute_security_policy.cloud_armor_policy) > 0 ? google_compute_security_policy.cloud_armor_policy[0].self_link : null
}
