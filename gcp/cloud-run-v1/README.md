# Google Cloud Run Module

This Terraform module deploys a Google Cloud Run service, configures public access (if desired), creates a Network Endpoint Group (NEG), and sets up a Load Balancer with SSL and domain configuration. Additionally, it includes a Cloud Build trigger for continuous integration and deployment.

## Usage

```hcl
module "cloud_run" {
  source                = "github.com/NandosUK/infrastructure/terraform-modules/gcp/cloud-run-v1"

  project_id                 = "your-gcp-project-id"
  name                       = "my-cloud-run-service"
  project_region             = "europe-west2"
  domains                    = ["example.com"]
  cloud_run_service_account  = "service-account-email"
  allow_public_access        = true
  sql_connection             = "connection-string"
  sharedVpcConnector         = "vpc-connector-name"
  environment                = "staging"
  branching_strategy         = {}
  artifact_repository        = "your-artifact-repository"
  create_trigger             = true
}

output "service_url" {
  value = module.cloud_run.service_url
}

output "service_name" {
  value = module.cloud_run.service_name
}

output "external_ip" {
  value = module.cloud_run.external_ip
}

```
### Inputs

| Name                         | Description                                                                   | Type          | Default                                                 |
|------------------------------|-------------------------------------------------------------------------------|---------------|---------------------------------------------------------|
| `project_id`                 | The ID of the GCP project                                                     | string        |                                                         |
| `name`                       | Unique name of the Cloud Run service                                          | string        |                                                         |
| `project_region`             | Cloud Run instance location, e.g., `europe-west2`                             | string        |                                                         |
| `domains`                    | List of domain names for SSL certificate (Optional)                           | list(string)  | `null`                                                  |
| `cloud_run_service_account`  | Service Account email for the Cloud Run service (Optional)                    | string        | `null`                                                  |
| `allow_public_access`        | Enable or disable public access to the service (Optional)                     | bool          | `true`                                                  |
| `sql_connection`             | Connection string to SQL database (Optional)                                  | string        | `null`                                                  |
| `sharedVpcConnector`         | Shared VPC connection string for internal network access (Optional)           | string        | `null`                                                  |
| `environment`                | Environment identifier, e.g., `staging` (Optional)                            | string        | `null`                                                  |
| `branching_strategy`         | Branching strategy for Cloud Build trigger (Optional)                          | object        | `{}`                                                    |
| `artifact_repository`        | Artifact repository for the service                                           | string        | `"europe-west2-docker.pkg.dev/mgt-build-56d2ff6b/nandos-central-docker"` |
| `create_trigger`             | Flag to create a Cloud Build trigger for the service                           | bool          | `true`                                                  |

### Outputs

| Name             | Description                      |
|------------------|----------------------------------|
| `service_url`    | URL of the deployed Cloud Run service  |
| `service_name`   | Name of the Cloud Run service         |
| `external_ip`    | External IP address of the Load Balancer |