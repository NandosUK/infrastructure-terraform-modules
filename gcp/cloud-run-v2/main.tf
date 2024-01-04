data "google_project" "current" {
  project_id = var.project_id
}

locals {
  cloud_armor_rules = var.cloud_armor.enabled ? yamldecode(file(var.cloud_armor.rules_file_path)) : []
}

# Resource configuration for deploying a Google Cloud Run service
resource "google_cloud_run_v2_service" "default" {
  name     = var.name           # Service name
  location = var.project_region # Deployment location
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    timeout = var.timeout
    containers {
      image = "gcr.io/cloudrun/hello"

      ports {
        container_port = var.container_port
      }

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
        initial_delay_seconds = var.liveness_probe_initial_delay
        timeout_seconds       = var.liveness_probe_timeout
        period_seconds        = var.liveness_probe_period
        failure_threshold     = var.liveness_probe_failure_threshold
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
      dynamic "env" {
        for_each = length(var.secrets) > 0 ? tomap({ for s in var.secrets : s => s }) : {}
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = "projects/${var.project_id}/secrets/${env.key}"
              version = "latest"
            }
          }
        }
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
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

    dynamic "vpc_access" {
      for_each = var.vpc_access_connector != null ? [1] : []
      content {
        connector = var.vpc_access_connector
        egress    = var.vpc_access_egress
      }
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
  count                 = var.enable_custom_domain ? 1 : 0
  name                  = "${var.name}-neg"
  network_endpoint_type = "SERVERLESS"       # Serverless NEG
  region                = var.project_region # Region
  cloud_run {
    service = google_cloud_run_v2_service.default.name # Associated Cloud Run service
  }
}

# Cloud Armor Security Policy

resource "google_compute_security_policy" "cloud_armor_policy" {
  count       = var.cloud_armor.enabled ? 1 : 0
  name        = "${var.name}-armor-policy"
  description = "A security policy for Cloud Armor."
  dynamic "rule" {
    for_each = local.cloud_armor_rules
    content {
      action   = rule.value.action
      priority = rule.value.priority
      match {
        versioned_expr = rule.value.match.versioned_expr
        config {
          src_ip_ranges = rule.value.match.config.src_ip_ranges
        }
      }
      description = rule.value.description
    }
  }
  # Default rule (do not remove)
  rule {
    action   = "allow"
    priority = 2147483647
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "default rule"
  }

  # Additional rules can go here with different priority values.
  # ...
}



# Load Balancer module using serverless NEGs
# View all options on https://github.com/terraform-google-modules/terraform-google-lb-http
module "lb-http" {
  count   = var.enable_custom_domain ? 1 : 0
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  project = var.project_id
  name    = "${var.name}-lb"
  version = "~> 9.0"

  # SSL and domain configuration
  managed_ssl_certificate_domains = [var.environment == "prod" ? "${var.name}.${var.domain_host}" : var.environment == "preview" ? "${var.name}-preview.${var.domain_host}" : "${var.name}-preprod.${var.domain_host}"]

  ssl                       = true
  https_redirect            = true # Enable HTTPS redirect
  random_certificate_suffix = true

  backends = {
    default = {
      groups = [
        {
          group = google_compute_region_network_endpoint_group.cloudrun_neg[count.index].id
        }
      ]

      description             = "Backend for Cloud Run service"
      enable_cdn              = false
      custom_request_headers  = ["X-Client-Geo-Location: {client_region_subdivision}, {client_city}"]
      custom_response_headers = ["X-Cache-Hit: {cdn_cache_status}"]

      # Clour Armor security
      security_policy = var.cloud_armor.enabled ? google_compute_security_policy.cloud_armor_policy[0].self_link : null

      log_config = {
        enable = false
      }
      iap_config = {
        enable = false
      }
    }
  }
}

resource "google_eventarc_trigger" "default" {
  for_each = { for i, trigger in var.eventarc_triggers : i => trigger }

  name     = "trigger-${google_cloud_run_v2_service.default.name}"
  location = var.project_region
  dynamic "matching_criteria" {
    for_each = each.value.matching_criteria
    content {
      attribute = matching_criteria.value.attribute
      value     = matching_criteria.value.value
      operator  = matching_criteria.value.operator
    }
  }
  event_data_content_type = each.value.event_data_content_type
  service_account         = var.cloud_run_service_account
  destination {
    cloud_run_service {
      service = google_cloud_run_v2_service.default.name
      path    = each.value.api_path
      region  = var.project_region
    }
  }
}

resource "google_project_iam_binding" "eventarc_cloud_run" {
  project = var.project_id
  role    = "roles/eventarc.eventReceiver"

  members = length(var.eventarc_triggers) > 0 && var.cloud_run_service_account != null && var.cloud_run_service_account != "" ? ["serviceAccount:${var.cloud_run_service_account}"] : []
}


resource "google_project_iam_binding" "eventarc_pubsub" {
  count   = length(var.eventarc_triggers) > 0 ? 1 : 0
  project = var.project_id
  role    = "roles/iam.serviceAccountTokenCreator"

  members = [
    "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
  ]
}

# Cloud Build trigger configuration
module "trigger_provision" {
  count           = var.create_trigger == true ? 1 : 0
  source          = "../cloud-cloudbuild-trigger"
  name            = "service-${var.name}-provision"
  repository_name = var.repository_name
  location        = var.location
  description     = "Provision ${var.name} Service (CI/CD)"
  filename        = "${var.service_path}/cloudbuild.yaml"
  include         = concat(["${var.service_path}/**"], var.dependencies)
  exclude         = ["${var.service_path}/functions/**"]
  environment     = var.environment

  # Substitution variables for Cloud Build Trigger
  substitutions = merge({
    _STAGE                    = "provision"
    _BUILD_ENV                = var.environment
    _SERVICE_NAME             = var.name
    _DOCKER_ARTIFACT_REGISTRY = var.artifact_repository
    _SERVICE_PATH             = var.service_path
    _LOCATION                 = var.project_region
    _SERVICE_ACCOUNT          = var.cloud_run_service_account
    },
    var.trigger_substitutions
  )
}

module "cloud_run_alerts" {
  source                = "../cloud-alerts"
  project_id            = var.project_id
  service_name          = var.name
  enabled               = var.alert_config.enabled
  threshold_value       = var.alert_config.threshold_value
  duration              = var.alert_config.duration
  alignment_period      = var.alert_config.alignment_period
  auto_close            = var.alert_config.auto_close
  notification_channels = var.alert_config.notification_channels
}
