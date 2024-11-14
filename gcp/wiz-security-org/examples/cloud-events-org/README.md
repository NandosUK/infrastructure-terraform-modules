# Integrate Google Cloud Organization with Wiz including Organization-level Cloud Events (Managed Identity)

The following Terraform provides an example of integrating a Google Cloud Organization with Wiz using a Wiz-managed identity.  This example also creates the necessary infrastructure for organization-level Cloud Event integration, providing the Pub/Sub Topic and Subscription ID as outputs.

```hcl
provider "google" {}

module "wiz" {
  source                           = "https://s3-us-east-2.amazonaws.com/wizio-public/deployment-v2/gcp/wiz-gcp-org-terraform-module.zip"
  org_id                           = "<Google_Cloud_Org_ID>"
  cloud_events_project_id          = "<Google_Cloud_Project_ID>"
  wiz_managed_identity_external_id = "wiz...@<Wiz_Provided_Project_ID>.iam.gserviceaccount.com"
  cloud_events                     = true
  data_scanning                    = true
  serverless_scanning              = true
}

output "wiz" {
  value = module.wiz
}
```
