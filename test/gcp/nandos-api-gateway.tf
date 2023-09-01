module "nandos_api" {
  source                 = "../../gcp/nandos-api-gateway"
  project_id             = "test-project-id"
  api_name               = "test-api"
  openapi_spec_file_path = "../assets/api-gateway-example.yml"
  project_region         = "europe-west2"
  cloud_run_url          = "https://test-project-id-ew2-abc-1234.a.run.app"
}
