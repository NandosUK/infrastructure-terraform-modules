provider "google" {}

module "wiz" {
  source                           = "../../"
  project_id                       = "wiz-security-project-id"
  wiz_managed_identity_external_id = "wiz-example-managed-identity@prod-us1.iam.gserviceaccount.com"
  data_scanning                    = true
  serverless_scanning              = true
}
