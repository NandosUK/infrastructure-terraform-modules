module "cloud-cloudbuild-trigger-1" {
  source           = "../../gcp/cloud-cloudbuild-trigger"
  name             = "my-trigger-1"
  description      = "A sample Google Cloud Build Trigger."
  repository_owner = "NandosUK"
  repository_name  = "forms"
  environment      = "prod"
  substitutions = {
    _LOCATION = "europe-west2"
  }
  include                 = ["**"]
  exclude                 = []
  disabled                = false
  tags                    = ["example-tag"]
  trigger_service_account = "49641569893-compute@developer.gserviceaccount.com"
  project_id              = var.gcp_project
}

module "cloud-cloudbuild-trigger-2" {
  source           = "../../gcp/cloud-cloudbuild-trigger"
  name             = "my-trigger-2"
  description      = "A sample Google Cloud Build Trigger."
  repository_owner = "NandosUK"
  repository_name  = "forms"
  environment      = "prod"
  substitutions = {
    _LOCATION = "europe-west2"
  }
  include                 = ["**"]
  exclude                 = []
  disabled                = false
  tags                    = ["example-tag"]
  trigger_service_account = ""
  project_id              = var.gcp_project
}

