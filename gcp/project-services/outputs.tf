output "activated_services" {
  value = [for item in google_project_service.active_services : item.service]
}
