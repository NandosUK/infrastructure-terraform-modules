
# Resource configuration for deploying a Google Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name     = var.name           # Service name
  location = var.project_region # Deployment location
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "gcr.io/cloudrun/hello"

      # Startup Probe
      startup_probe {
        initial_delay_seconds = var.startup_probe_initial_delay
        timeout_seconds       = var.startup_probe_timeout
        period_seconds        = var.startup_probe_period
        failure_threshold     = var.startup_probe_failure_threshold
        tcp_socket {
          port = var.startup_probe_port
        }
      }

      # Liveness Probe
      liveness_probe {
        http_get {
          path = var.liveness_probe_path
        }
      }

      # Conditional environment variables
      dynamic "env" {
        for_each = var.env_vars
        content {
          name  = env.key
          value = env.value
        }
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      # Conditional secrets
      dynamic "env" {
        for_each = var.secrets
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "1"
            }
          }
        }
      }
      # Conditional volume_mounts
      dynamic "volume_mounts" {
        for_each = var.sql_connection != null ? [1] : []
        content {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }

    }

    scaling {
      max_instance_count = var.max_scale
      min_instance_count = var.min_scale
    }

    dynamic "volumes" {
      for_each = var.sql_connection != null ? [1] : [] # Include the block only if var.sql_connection is not null
      content {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [var.sql_connection]
        }
      }
    }
  }
  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}



# Resource to allow public access to the Cloud Run service
resource "google_cloud_run_service_iam_binding" "noauth" {
  count    = var.allow_public_access == true ? 1 : 0 # Conditionally create based on public access flag
  location = google_cloud_run_v2_service.default.location
  project  = google_cloud_run_v2_service.default.project
  service  = google_cloud_run_v2_service.default.name
  role     = "roles/run.invoker" # Role for invoking the service
  members  = ["allUsers"]        # Allow all users
}

# Network Endpoint Group (NEG) for Cloud Run service
resource "google_compute_region_network_endpoint_group" "cloudrun_neg" {
  name                  = "${var.name}-neg"
  network_endpoint_type = "SERVERLESS"       # Serverless NEG
  region                = var.project_region # Region
  cloud_run {
    service = google_cloud_run_v2_service.default.name # Associated Cloud Run service
  }
}

# Load Balancer module using serverless NEGs
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  project = var.project_id
  name    = "${var.name}-lb"
  version = "9.1.0"

  # SSL and domain configuration
  managed_ssl_certificate_domains = var.domains != null ? var.domains : []
  ssl                             = var.domains != null ? true : false
  https_redirect                  = true # Enable HTTPS redirect
  random_certificate_suffix       = true

  backends = {
    default = {
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cloudrun_neg.id
        }
      ]

      description             = "Backend for Cloud Run service"
      enable_cdn              = false
      custom_request_headers  = ["X-Client-Geo-Location: {client_region_subdivision}, {client_city}"]
      custom_response_headers = ["X-Cache-Hit: {cdn_cache_status}"]
      security_policy         = null
      log_config = {
        enable = false
      }
      iap_config = {
        enable = false
      }
    }
  }
}

# Cloud Build trigger configuration
module "trigger_provision" {
  count        = var.create_trigger == true ? 1 : 0
  source       = "../cloud-cloudbuild-trigger"
  name         = "service-${var.name}-provision"
  description  = "Provision ${var.name} Service (CI/CD)"
  filename     = "services/${var.name}/cloudbuild.yaml"
  include      = ["services/${var.name}/**"]
  exclude      = ["services/${var.name}/functions/**"]
  branch       = var.branching_strategy.provision.branch
  invert_regex = var.branching_strategy.provision.invert_regex
  # Substitution variables for Cloud Build
  substitutions = {
    _STAGE                    = "provision"
    _BUILD_ENV                = var.environment
    _SERVICE_NAME             = var.name
    _DOCKER_ARTIFACT_REGISTRY = var.artifact_repository
    _SERVICE_PATH             = "services/${var.name}"
    _LOCATION                 = var.project_region
    _SERVICE_ACCOUNT          = var.cloud_run_service_account
  }
}