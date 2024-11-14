# Wiz Module for organization
module "wiz_security_organisation" {
  source                           = "../../gcp/wiz-security-org"
  org_id                           = "1018445666131"
  wiz_managed_identity_external_id = "test-sa-123-123@prod-eu9.iam.gserviceaccount.com"
  serverless_scanning              = true
  data_scanning                    = true
  forensic                         = true
}
