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
    _RUNTIME               = "nodejs16"
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
