module "cloud-function-my-awesome-cf" {
  source                = "../../gcp/cloud-function-gen2"
  function_name         = "my-awesome-cf"
  function_type         = "node"
  function_description  = "My awesome cloud function"
  environment           = "preview"
  region                = "europe-west2"
  notification_channels = []
  service_name          = "my-awesome-cf"
  bucket_functions      = "test-bucket-functions"
  service_account_email = "test-service-account-email"
  function_path         = "services/my-awesome-cf/functions/my-awesome-cf"
  max_instance_count    = 3
  min_instance_count    = 1
  branching_strategy    = "master"
  repository_name       = "my-awesome-cf"
  project_id            = "mgt-build-56d2ff6b"
  timeout_seconds       = 60
  trigger_substitutions = {
    _ENTRYPOINT            = "helloWorld"
    _FUNCTION_SA           = "test-service-account-email"
    _FUNCTION_PATH         = "services/my-awesome-cf/functions/my-awesome-cf"
    _FUNCTION_TYPE_TRIGGER = "trigger-http"

  }
  environment_variables = {
    LOCATION = "europe-west2"
  }
  secret_keys          = []
  threshold_value      = 0
  function_entry_point = "helloWorld"
}

// Exercises cloudbuild_yaml_suffix: two functions built from one source
// directory via cloudbuild-collector.yaml and cloudbuild-pubsub.yaml.
// branching_strategy and notification_channels are deliberately omitted here to
// cover their defaults.
module "cloud-function-suffixed" {
  for_each = toset(["collector", "pubsub"])

  source                 = "../../gcp/cloud-function-gen2"
  function_name          = "my-awesome-cf-${each.key}"
  function_type          = "node"
  function_description   = "My awesome ${each.key} cloud function"
  cloudbuild_yaml_suffix = "-${each.key}"
  environment            = "preview"
  region                 = "europe-west2"
  service_name           = "my-awesome-cf"
  bucket_functions       = "test-bucket-functions"
  service_account_email  = "test-service-account-email"
  max_instance_count     = 3
  min_instance_count     = 1
  repository_name        = "my-awesome-cf"
  project_id             = "mgt-build-56d2ff6b"
  timeout_seconds        = 60
  trigger_substitutions = {
    _ENTRYPOINT            = "helloWorld"
    _FUNCTION_SA           = "test-service-account-email"
    _FUNCTION_TYPE_TRIGGER = "trigger-http"
  }
  secret_keys          = []
  threshold_value      = 0
  function_entry_point = "helloWorld"
}

// Exercises the adoption gaps: secrets whose env var name differs from the
// secret name, per-instance concurrency, ingress, VPC egress and labels.
// Alert config is set properly here so the check blocks stay quiet.
module "cloud-function-adoption-gaps" {
  source               = "../../gcp/cloud-function-gen2"
  function_name        = "adoption-gaps-cf"
  function_type        = "node"
  function_description = "Covers secret name mapping and service_config fields"
  environment          = "preview"
  region               = "europe-west2"
  service_name         = "adoption-gaps-cf"
  bucket_functions     = "test-bucket-functions"
  repository_name      = "my-awesome-cf"
  project_id           = "mgt-build-56d2ff6b"
  function_entry_point = "helloWorld"

  trigger_substitutions = {
    _FUNCTION_SA = "test-service-account-email"
  }

  // Same name on both sides: shorthand.
  secret_keys = ["CONSENT_API_TOKEN"]

  // Name differs, non-latest version, or another project: long form.
  secret_environment_variables = [
    { key = "AUTH_KEY", secret = "DISABLE_EXPIRED_JOBS_AUTH_KEY" },
    { key = "OKTA_API_KEY", secret = "PROFILE_API_OKTA_API_KEY", version = "3" },
    { key = "CROSS_PROJECT", secret = "SHARED_TOKEN", project_id = "other-project" },
  ]

  max_instance_request_concurrency = 4
  ingress_settings                 = "ALLOW_INTERNAL_AND_GCLB"
  vpc_connector                    = "projects/mgt-build-56d2ff6b/locations/europe-west2/connectors/test"
  vpc_connector_egress_settings    = "PRIVATE_RANGES_ONLY"
  labels                           = { team = "identity" }

  alert_config = {
    enabled               = true
    threshold_value       = 1
    duration              = 300
    alignment_period      = 60
    auto_close            = 86400
    notification_channels = ["projects/mgt-build-56d2ff6b/notificationChannels/123"]
  }
}
