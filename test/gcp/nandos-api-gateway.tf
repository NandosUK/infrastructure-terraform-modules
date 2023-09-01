module "nandos_api" {
  source                 = "../../gcp/nandos-api-gateway"
  project_id             = "test-project-id"
  project_region         = "europe-west2"
  cloud_run_url          = "https://test-cloud-run-service-xyz.a.run.app"
  api_name               = "test-api"
  openapi_spec_file_path = "../assets/api-gateway-example.yml"
}
