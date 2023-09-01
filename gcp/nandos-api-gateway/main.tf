# Create a service account for the API Gateway
resource "google_service_account" "api_gateway_sa" {
  account_id   = "${var.api_name}-api-gateway-sa"
  display_name = "API Gateway ${var.api_name}"
  project      = var.project_id
}

# API Gateway API Resource
resource "google_api_gateway_api" "nandos_api" {
  provider = google-beta
  api_id   = var.api_name
  project  = var.project_id
}

# API Gateway API Config
resource "google_api_gateway_api_config" "nandos_api_config" {
  provider      = google-beta
  api           = google_api_gateway_api.nandos_api.api_id
  api_config_id = "${var.api_name}-config"
  project       = var.project_id

  openapi_documents {
    document {
      path     = var.openapi_spec_file_path
      contents = filebase64(var.openapi_spec_file_path)
    }
  }
}

# API Gateway
resource "google_api_gateway_gateway" "nandos_api_gateway" {
  provider   = google-beta
  gateway_id = "${var.api_name}-gateway"
  api_config = google_api_gateway_api_config.nandos_api_config.id
  project    = var.project_id
  region     = var.project_region
}
