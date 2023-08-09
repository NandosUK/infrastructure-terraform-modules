module "cloud-cloudbuild-trigger" {
  source           = "../../gcp/cloud-cloudbuild-trigger"
  name             = "my-trigger"
  description      = "A sample Google Cloud Build Trigger."
  repository_owner = "NandosUK"
  repository_name  = "my-repo"
  branch           = "main"
  invert_regex     = false
  substitutions = {
    _LOCATION = "europe-west2"
  }
  include  = ["**"]
  exclude  = []
  disabled = false
  tags     = ["example-tag"]
}
