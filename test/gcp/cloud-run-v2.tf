module "cloud-run" {
  source              = "../../gcp/cloud-run-v2"
  project_id          = "test-project-id"
  name                = "my-awesome-api"
  project_region      = "europe-west2"
  allow_public_access = true
  create_trigger      = true
  environment         = "preview"
  repository_name     = "my-repo-in-github"
  service_path        = "/services/my-awesome-api"
  env_vars = {
    "ENVIRONMENT" = "preview"
    "DEBUG"       = "true"
    # ... add more as needed
  }
  secrets = [
    "SECRET_ONE",
    "SECRET_TWO"
  ]
  enable_cloud_armor = true
  alert_config = {
    enabled               = true
    threshold_value       = 10.0
    duration              = 300
    alignment_period      = 60
    auto_close            = 86400
    notification_channels = []
  }
}
