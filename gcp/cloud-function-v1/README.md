# Google Cloud Function Terraform Module

This module provisions a basic Google Cloud Function version 1

## Usage

```hcl
module "gcp_cloud_function" {
  source                = "github.com/NandosUK/infrastructure/terraform-modules/gcp/cloud-function-v1"
  function_name         = "my-function"
  description           = "A sample Google Cloud Function."
  runtime               = "python39"
  source_archive_bucket = "my-source-bucket"
  source_archive_object = "function-code.zip"
  entry_point           = "main"
  trigger_http          = true
}
```

## Inputs

Refer to variables.tf for input parameters.

## Outputs

Refer to outputs.tf for output values.