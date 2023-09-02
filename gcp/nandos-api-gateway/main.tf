locals {
  openapi_contents = filebase64(var.openapi_spec_file_path)
  config_hash      = md5(local.openapi_contents)
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

# Create a managed SSL certificate
resource "google_compute_managed_ssl_certificate" "custom_ssl_cert" {
  name    = "custom-ssl-cert"
  project = var.project_id
  managed {
    domains = [var.custom_domain]
  }
}

# Reserve a Global IP Address
resource "google_compute_global_address" "default" {
  name    = "global-address"
  project = var.project_id
}

# HTTP Health Check
resource "google_compute_health_check" "default" {
  name               = "http-health-check"
  timeout_sec        = 5
  check_interval_sec = 5
  http_health_check {
    port = "80"
  }
}

# Create a Backend Service
resource "google_compute_backend_service" "backend_service" {
  name       = "backend-service"
  enable_cdn = false
  port_name  = "http"
  protocol   = "HTTP"
  project    = var.project_id

  backend {
    group = google_api_gateway_gateway.nandos_api_gateway.gateway_id
  }

  health_checks = [
    google_compute_health_check.default.self_link
  ]
}

# Create a URL Map
resource "google_compute_url_map" "url_map" {
  name            = "url-map"
  default_service = google_compute_backend_service.backend_service.self_link
  project         = var.project_id
}

# HTTPS Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name             = "https-proxy"
  url_map          = google_compute_url_map.url_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.custom_ssl_cert.self_link]
  project          = var.project_id
}

# Global Forwarding Rule for HTTPS
resource "google_compute_global_forwarding_rule" "https_global_forwarding_rule" {
  name       = "https-global-forwarding-rule"
  target     = google_compute_target_https_proxy.https_proxy.self_link
  ip_address = google_compute_global_address.default.address
  port_range = "443"
  project    = var.project_id
}

# Output URLs and other details
output "api_gateway_url_text" {
  value = "Your API Gateway URL is: ${google_api_gateway_gateway.nandos_api_gateway.default_hostname}"
}

output "custom_domain_text" {
  value = "Your custom domain is: ${var.custom_domain}"
}

output "load_balancer_ip" {
  value = "Your Load Balancer IP is: ${google_compute_global_address.default.address}"
}
