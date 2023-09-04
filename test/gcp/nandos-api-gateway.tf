module "nando-api-gateway-api-1" {
  source                 = "../../gcp/nandos-api-gateway"
  project_id             = "test-project-id"
  api_name               = "test-api"
  openapi_spec_file_path = "../assets/api-gateway-example.yml"
  project_region         = "europe-west2"
}
