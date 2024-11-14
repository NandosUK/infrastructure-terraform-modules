# Wiz Module for project
module "wiz_security_project" {
  source                           = "../../gcp/wiz-security-project"
  project_id                       = "nandos-api-platform"
  wiz_managed_identity_external_id = "test-sa-123-123@prod-eu9.iam.gserviceaccount.com"
  serverless_scanning              = true
  data_scanning                    = true
  forensic                         = true
}
