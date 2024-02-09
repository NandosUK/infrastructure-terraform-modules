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

output "default_backend_self_links" {
  description = "Self links of default backend services"
  value = {
    for key, value in additional_backend_services : key => length(module.lb-http) > 0 ? module.lb-http[0].backend_services["${key}"].self_link : null
  }
}
