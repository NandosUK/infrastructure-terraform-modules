locals {
  data_ingestor_project_id = var.environment == "dev" ? "preview-data-ingestor-c0edc062" : var.environment == "preview" ? "preview-data-ingestor-c0edc062" : var.environment == "preprod" ? "preprod-data-ingestor-6ee5b6e2" : var.environment == "prod" ? "prod-data-ingestor-40f9b4fb" : "preview-data-ingestor-c0edc062"
  topic_name               = "projects/${local.data_ingestor_project_id}/topics/${var.topic_name}"
}


resource "google_pubsub_subscription" "pubsub_subscription" {
  name                       = "${var.name}-subscription"
  topic                      = local.topic_name
  ack_deadline_seconds       = var.ack_deadline_seconds
  message_retention_duration = var.message_retention_duration
  retain_acked_messages      = var.retain_acked_messages
  enable_message_ordering    = var.enable_message_ordering

  labels = {
    info        = "terraform-managed-subscription"
    environment = var.environment
    name        = var.name
  }

  dynamic "push_config" {
    for_each = var.subscription_type == "push" ? [1] : []
    content {
      push_endpoint = var.push_endpoint

      attributes = {
        x-goog-version = "v1"
        environment    = var.environment
        service        = "data-ingestor"
      }

      oidc_token {
        service_account_email = var.service_account_email
        audience              = var.audience
      }
    }
  }
}
