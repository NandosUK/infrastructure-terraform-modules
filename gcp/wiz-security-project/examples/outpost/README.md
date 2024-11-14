# Integrate Google Cloud Project with Wiz using an Outpost (Managed Identity)

The following provides an example of integrating a Google Cloud Project with Wiz using an Outpost and a Wiz-managed identity.

```hcl
provider "google" {}

module "wiz" {
  source                           = "https://s3-us-east-2.amazonaws.com/wizio-public/deployment-v2/gcp/wiz-gcp-project-terraform-module.zip"
  project_id                       = "<Google_Cloud_Project_ID>"
  wiz_managed_identity_external_id = "wiz...@<Wiz_Provided_Project_ID>.iam.gserviceaccount.com"
  worker_service_account_id        = "wiz-worker-sa@<Outpost_Project_ID>.iam.gserviceaccount.com"
  data_scanning                    = true
  serverless_scanning              = true
}
```
