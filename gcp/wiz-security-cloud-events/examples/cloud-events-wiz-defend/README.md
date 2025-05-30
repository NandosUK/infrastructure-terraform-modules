# Integrate Google Cloud Organization with Wiz Cloud Events including Wiz Defend log sources

The following Terraform provides an example of integrating a Google Cloud Organization with Wiz Cloud Events, including Wiz Defend log sources, providing the Pub/Sub Topic and Subscription ID as outputs.

```hcl
provider "google" {}

module "wiz_cloud_events" {
  source                = "https://s3-us-east-2.amazonaws.com/wizio-public/deployment-v2/gcp/wiz-gcp-cloud-events-terraform-module.zip"
  org_id                = "<Google_Cloud_Org_ID>"
  project_id            = "<Google_Cloud_Project_ID>"
  service_account_email = "wiz...@<Wiz_Provided_Project_ID>.iam.gserviceaccount.com"

  enable_wiz_defend_log_sources = true
}
```
