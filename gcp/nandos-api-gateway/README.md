# Nando's API Terraform Module

This Terraform module provisions a complete API environment on Google Cloud Platform. The module sets up API Gateway, API Config, and optional integration with backend services like Cloud Run, Cloud Functions, etc. The module allows customization to fit different use-cases and environments.

## Usage

```hcl
module "nandos_api" {
  source                 = "github.com/NandosUK/infrastructure-terraform-modules//gcp/nandos-api-gateway"
  project_id             = "test-project-id"
  api_name               = "test-api"
  openapi_spec_file_path = "./path/to/spec.yaml"
  project_region         = "europe-west2"
  cloud_run_url          = "https://test-project-id-ew2-abc-1234.a.run.app"
}

```
