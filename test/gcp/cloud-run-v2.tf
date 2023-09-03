module "cloud-run" {
  source              = "../../gcp/cloud-run-v2"
  project_id          = "test-project-id"
  name                = "my-awesome-api"
  project_region      = "europe-west2"
  allow_public_access = true
  create_trigger      = false
  environment         = "test"
  branching_strategy  = {} # Provide appropriate dummy values if needed
  env_vars = {
    "ENVIRONMENT" = "test"
    "DEBUG"       = "true"
    # ... add more as needed
  }
  secrets = [
    "SECRET_ONE",
    "SECRET_TWO"
  ]
}
