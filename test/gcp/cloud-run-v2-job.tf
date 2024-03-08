module "cloud-run-api-my-awesome-job" {
  source                    = "../../gcp/cloud-run-v2-job"
  project_id                = "mgt-build-56d2ff6b"
  name                      = "example-service-name"
  project_region            = "europe-west2"
  environment               = "dev"
  artifact_repository       = "europe-west2-docker.pkg.dev/your-project-id/your-repo"
  repository_name           = "your-github-repo-name"
  service_path              = "/services/example-service"
  create_trigger            = true
  cloud_run_service_account = "your-cloud-run-invoker@your-project-id.iam.gserviceaccount.com"
  max_retries               = 5
  timeout                   = "1800s" # 30 minutes
  memory_limit              = "4096Mi"
  cpu_limit                 = "2000m"
  location                  = "global" # or specify another location

  # Environment Variables and Secrets
  env_vars = {
    "EXAMPLE_VAR" = "example_value",
    "ANOTHER_VAR" = "another_value"
  }
  secrets = [
    "EXAMPLE_SECRET",
    "ANOTHER_SECRET"
  ]

  # Alert Configuration
  alert_config = {
    enabled               = true
    threshold_value       = 10.0
    duration              = 300
    alignment_period      = 60
    auto_close            = 86400
    notification_channels = ["your-notification-channel-id"]
  }

  # Cloud Build Trigger Substitutions and Dependencies
  trigger_substitutions = {
    "_EXAMPLE_SUBSTITUTION" = "example_value"
  }
  dependencies = [
    "path/to/dependency1",
    "path/to/dependency2"
  ]
}
