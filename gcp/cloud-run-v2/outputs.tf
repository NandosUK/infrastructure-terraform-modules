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
  value       = module.lb-http.external_ip
}
