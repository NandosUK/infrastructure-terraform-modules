module "api-gateway-api-1" {
  source                 = "../../gcp/api-gateway"
  project_id             = "test-project-id"
  api_name               = "test-api"
  openapi_spec_file_path = "../assets/api-gateway-example.yml"
  project_region         = "europe-west2"
  environment            = "preview"
  api_keys               = [
    {
      name         = "default"
      display_name = "Default API Key for testing"
      methods      = ["GET*"]
    },
  ]
}
