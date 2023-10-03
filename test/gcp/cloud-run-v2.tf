module "cloud-run-api-my-awesome-api" {
  source              = "../../gcp/cloud-run-v2"
  project_id          = "my-awesome-project"
  name                = "my-awesome-api"
  project_region      = "europe-west2"
  allow_public_access = true
  create_trigger      = true
  environment         = "preview"
  repository_name     = "my-repo-in-github"
  service_path        = "/services/my-awesome-api"
  dependencies        = ["services/shared/**", "services/types/**"]

  startup_probe_initial_delay  = 5
  liveness_probe_initial_delay = 10

  env_vars = {
    "ENVIRONMENT" = "preview"
    "DEBUG"       = "true"
    # ... add more as needed
  }
  secrets = [
    "SECRET_ONE",
    "SECRET_TWO"
  ]
  cloud_armor = {
    enabled         = true
    rules_file_path = "assets/cloud-armor-rules-example.yaml"
  }
  alert_config = {
    enabled               = true
    threshold_value       = 10.0
    duration              = 300
    alignment_period      = 60
    auto_close            = 86400
    notification_channels = []
  }
  eventarc_triggers = [
    {
      api_path                = "/api/my-trigger-receiver"
      event_data_content_type = "application/protobuf"
      matching_criteria = [{
        attribute = "type"
        value     = "google.cloud.firestore.document.v1.created",
        },
        {
          attribute = "database"
          value     = "(default)"
      }]
    }
  ]
}


