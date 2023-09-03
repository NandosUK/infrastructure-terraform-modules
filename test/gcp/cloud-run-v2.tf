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
  alert_config = {
    alert_notification_channels = ["your-notification-channel-id"]
    error_rate_threshold        = 20.0
    error_rate_duration         = "600s"
    latency_threshold           = 2000.0
    latency_duration            = "600s"

    # Additional alert settings
    client_error_rate_threshold = 50.0
    client_error_rate_duration  = "300s"
    traffic_volume_threshold    = 1000
    traffic_volume_duration     = "300s"
    cpu_utilization_threshold   = 90
    cpu_utilization_duration    = "300s"
  }
}
