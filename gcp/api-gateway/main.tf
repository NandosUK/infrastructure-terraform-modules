locals {
  openapi_contents = filebase64(var.openapi_spec_file_path)
  config_hash      = md5(local.openapi_contents)
  domains          = ["gateway-${var.api_name}.api.nandos.services"]
}


# Create a service account for the API Gateway
resource "google_service_account" "api_gateway_sa" {
  account_id   = "${var.api_name}-api-gateway-sa"
  display_name = "API Gateway ${var.api_name}"
  project      = var.project_id
}

# Add permission for service account to invoke the Cloud Run service
resource "google_project_iam_member" "cloud_run_invoker" {
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.api_gateway_sa.email}"
  project = var.project_id
}

# Add permission for service account to invoke the Cloud Function
resource "google_project_iam_member" "cloud_function_invoker" {
  role    = "roles/cloudfunctions.invoker"
  member  = "serviceAccount:${google_service_account.api_gateway_sa.email}"
  project = var.project_id
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
  api_config_id = "my-api-config-${local.config_hash}"
  project       = var.project_id

  openapi_documents {
    document {
      path     = var.openapi_spec_file_path
      contents = filebase64(var.openapi_spec_file_path)
    }
  }
  lifecycle {
    create_before_destroy = true
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


resource "google_compute_region_network_endpoint_group" "api_g_neg" {
  provider              = google-beta
  project               = var.project_id
  name                  = "${var.api_name}-neg1"
  network_endpoint_type = "SERVERLESS"
  region                = var.project_region
  serverless_deployment {
    platform = "apigateway.googleapis.com"
    resource = google_api_gateway_gateway.nandos_api_gateway.gateway_id
  }
}

resource "google_compute_backend_service" "api_g_backend_service" {
  name       = "${var.api_name}-backend-service"
  enable_cdn = false
  backend {
    group = google_compute_region_network_endpoint_group.api_g_neg.id
  }
}

resource "google_compute_url_map" "urlmap" {
  name            = "${var.api_name}-urlmap"
  description     = "URL map for ${var.api_name}"
  default_service = google_compute_backend_service.api_g_backend_service.id

}

resource "google_compute_managed_ssl_certificate" "default" {
  provider = google-beta
  project  = var.project_id
  name     = "${var.api_name}-cert"

  lifecycle {
    create_before_destroy = true
  }

  managed {
    domains = local.domains
  }
}


output "api_gateway_url_text" {
  value = "Your API Gateway URL is: ${google_api_gateway_gateway.nandos_api_gateway.default_hostname}"
}
