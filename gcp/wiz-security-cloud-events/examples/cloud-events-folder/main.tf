provider "google" {}

module "wiz_cloud_events" {
  source = "../../"

  integration_type      = "FOLDER"
  project_id            = "wiz-security-project-id"
  service_account_email = "wiz-example-managed-identity@prod-us1.iam.gserviceaccount.com"

  monitored_folders = ["123456789012", "234567891234"]
}
