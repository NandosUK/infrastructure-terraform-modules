# Integrate Google Cloud Organization with Wiz (Managed Identity)

The following provides an example of integrating a Google Cloud Organization with Wiz using a Wiz-managed identity.

```hcl
provider "google" {}

module "wiz" {
  source                           = "https://s3-us-east-2.amazonaws.com/wizio-public/deployment-v2/gcp/wiz-gcp-org-terraform-module.zip"
  org_id                           = "<Google_Cloud_Org_ID>"
  wiz_managed_identity_external_id = "wiz...@<Wiz_Provided_Project_ID>.iam.gserviceaccount.com"
  data_scanning                    = true
  serverless_scanning              = true
}
```
