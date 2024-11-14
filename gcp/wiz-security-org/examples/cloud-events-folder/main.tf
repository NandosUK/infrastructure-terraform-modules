provider "google" {}

module "wiz" {
  source                           = "../../"
  org_id                           = "987654321098"
  cloud_events_project_id          = "wiz-security-project-id"
  wiz_managed_identity_external_id = "wiz-example-managed-identity@prod-us1.iam.gserviceaccount.com"
  cloud_events                     = true
  cloud_events_folders             = ["123456789012", "234567891234"]
  data_scanning                    = true
  serverless_scanning              = true
}

output "wiz" {
  value = module.wiz
}
