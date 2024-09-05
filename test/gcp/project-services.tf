module "project-services-1" {
  source     = "../../gcp/project-services"
  project_id = "test-project-id"
  activate_services = [
    "compute.googleapis.com",
    "firestore.googleapis.com",
  ]

  timeouts_config = {
    create = "1m"
    read   = "1m"
    update = "1m"
    delete = "1m"
  }

  disable_dependent_services = true
}
