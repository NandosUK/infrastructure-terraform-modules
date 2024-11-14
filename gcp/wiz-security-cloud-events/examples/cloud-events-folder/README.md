# Integrate Google Cloud Folders with Wiz Cloud Events

The following Terraform provides an example of integrating a Google Cloud Folders with Wiz Cloud Events, providing the Pub/Sub Topic and Subscription ID as outputs.

```hcl
provider "google" {}

module "wiz_cloud_events" {
  source                = "https://s3-us-east-2.amazonaws.com/wizio-public/deployment-v2/gcp/wiz-gcp-cloud-events-terraform-module.zip"
  integration_type      = "FOLDER"
  project_id            = "<Google_Cloud_Project_ID>"
  service_account_email = "wiz...@<Wiz_Provided_Project_ID>.iam.gserviceaccount.com"

  monitored_folders = ["<Folder_ID_1>", "<Folder_ID_2>"]
}
```
