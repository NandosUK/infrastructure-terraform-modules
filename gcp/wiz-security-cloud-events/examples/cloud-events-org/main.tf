provider "google" {}

module "wiz_cloud_events" {
  source = "../../"

  org_id                = "987654321098"
  project_id            = "wiz-security-project-id"
  service_account_email = "wiz-example-managed-identity@prod-us1.iam.gserviceaccount.com"
}
