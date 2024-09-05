resource "google_project_service" "active_services" {
  for_each = toset(var.activate_services)
  project  = var.project_id
  service  = each.key

  timeouts {
    create = var.timeouts_config.create
    read   = var.timeouts_config.read
    update = var.timeouts_config.update
    delete = var.timeouts_config.delete
  }


  disable_dependent_services = var.disable_dependent_services
}
