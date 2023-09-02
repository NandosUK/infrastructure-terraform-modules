locals {
  host              = google_api_gateway_gateway.nandos_api_gateway.gateway_id # Replace with actual host value
  openapi_template  = templatefile(var.openapi_spec_file_path, { host = local.host })
  temp_openapi_path = "${path.module}/temp_openapi.yaml"
}

resource "null_resource" "write_temp_openapi" {
  provisioner "local-exec" {
    command = "echo '${local.openapi_template}' > ${local.temp_openapi_path}"
  }
  triggers = {
    openapi_contents = local.openapi_template
  }
}

locals {
  openapi_contents = filebase64(local.temp_openapi_path)
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

output "api_gateway_url" {
  value = "Your API Gateway URL is: ${google_api_gateway_gateway.nandos_api_gateway.default_hostname}"
}
