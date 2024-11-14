locals {
  log_sink_filter = var.enable_wiz_defend_log_sources ? var.wiz_defend_log_sink_filter : var.log_sink_filter

  project_id = length(var.project_id) == 0 ? data.google_project.selected[0].project_id : var.project_id
  projects   = var.integration_type == "PROJECT" ? concat([local.project_id], var.monitored_projects) : var.monitored_projects

  writer_identities = concat(
    google_logging_organization_sink.wiz_audit_logs[*].writer_identity,
    google_logging_folder_sink.wiz_audit_logs[*].writer_identity,
    google_logging_project_sink.wiz_audit_logs[*].writer_identity
  )
}

data "google_project" "selected" {
  count = length(var.project_id) == 0 ? 1 : 0
}

resource "random_id" "uniq" {
  byte_length = 4
}

resource "google_pubsub_topic" "wiz_audit_logs" {
  project = local.project_id

  name                       = var.pubsub_topic_name
  message_retention_duration = var.message_retention_duration

  depends_on = [time_sleep.required_apis]
}

resource "google_pubsub_subscription" "wiz_audit_logs" {
  project = local.project_id

  name                       = var.pubsub_subscription_name
  topic                      = google_pubsub_topic.wiz_audit_logs.name
  message_retention_duration = var.message_retention_duration

  expiration_policy {
    ttl = ""
  }
}

resource "google_pubsub_subscription_iam_binding" "wiz_audit_logs" {
  count = var.iam_policy_type == "BINDING" ? 1 : 0

  project = local.project_id

  role         = "roles/pubsub.subscriber"
  members      = ["serviceAccount:${var.service_account_email}"]
  subscription = google_pubsub_subscription.wiz_audit_logs.name
}

resource "google_pubsub_subscription_iam_member" "wiz_audit_logs" {
  count = var.iam_policy_type == "MEMBER" ? 1 : 0

  project = local.project_id

  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.service_account_email}"
  subscription = google_pubsub_subscription.wiz_audit_logs.name
}

resource "google_logging_organization_sink" "wiz_audit_logs" {
  count  = var.integration_type == "ORGANIZATION" && length(var.monitored_folders) + length(var.monitored_projects) == 0 ? 1 : 0
  org_id = var.org_id

  name             = "wiz-audit-logs-sink-${random_id.uniq.hex}"
  description      = "Send organization scope audit logs to a Pub/Sub for export to Wiz"
  destination      = "pubsub.googleapis.com/${google_pubsub_topic.wiz_audit_logs.id}"
  include_children = true

  filter = local.log_sink_filter

  dynamic "exclusions" {
    for_each = var.enable_wiz_defend_log_sources ? concat(var.log_sink_exclusions, var.wiz_defend_additional_log_sink_exclusions) : var.log_sink_exclusions
    content {
      name        = exclusions.value["name"]
      description = lookup(exclusions.value, "description", null)
      filter      = exclusions.value["filter"]
    }
  }
}

resource "google_organization_iam_audit_config" "k8s_data_access_logs" {
  count   = var.enable_gke_data_access_logs && var.integration_type == "ORGANIZATION" && length(var.monitored_folders) + length(var.monitored_projects) == 0 ? 1 : 0
  org_id  = var.org_id
  service = "container.googleapis.com"

  audit_log_config {
    log_type         = "ADMIN_READ"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
  audit_log_config {
    log_type         = "DATA_READ"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
  audit_log_config {
    log_type         = "DATA_WRITE"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
}

resource "google_logging_folder_sink" "wiz_audit_logs" {
  count  = contains(["FOLDER", "ORGANIZATION"], var.integration_type) ? length(var.monitored_folders) : 0
  folder = var.monitored_folders[count.index]

  name             = "wiz-audit-logs-sink-${random_id.uniq.hex}"
  description      = "Send folder scope audit logs to a Pub/Sub for export to Wiz"
  destination      = "pubsub.googleapis.com/${google_pubsub_topic.wiz_audit_logs.id}"
  include_children = true

  filter = local.log_sink_filter

  dynamic "exclusions" {
    for_each = var.enable_wiz_defend_log_sources ? concat(var.log_sink_exclusions, var.wiz_defend_additional_log_sink_exclusions) : var.log_sink_exclusions
    content {
      name        = exclusions.value["name"]
      description = lookup(exclusions.value, "description", null)
      filter      = exclusions.value["filter"]
    }
  }
}

resource "google_folder_iam_audit_config" "k8s_data_access_logs" {
  count   = var.enable_gke_data_access_logs && contains(["FOLDER", "ORGANIZATION"], var.integration_type) ? length(var.monitored_folders) : 0
  folder  = var.monitored_folders[count.index]
  service = "container.googleapis.com"

  audit_log_config {
    log_type         = "ADMIN_READ"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
  audit_log_config {
    log_type         = "DATA_READ"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
  audit_log_config {
    log_type         = "DATA_WRITE"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
}

resource "google_logging_project_sink" "wiz_audit_logs" {
  count   = length(local.projects)
  project = local.projects[count.index]

  name                   = "wiz-audit-logs-sink-${random_id.uniq.hex}"
  description            = "Send project scope audit logs to a Pub/Sub for export to Wiz"
  destination            = "pubsub.googleapis.com/${google_pubsub_topic.wiz_audit_logs.id}"
  unique_writer_identity = true

  filter = local.log_sink_filter

  dynamic "exclusions" {
    for_each = var.enable_wiz_defend_log_sources ? concat(var.log_sink_exclusions, var.wiz_defend_additional_log_sink_exclusions) : var.log_sink_exclusions
    content {
      name        = exclusions.value["name"]
      description = lookup(exclusions.value, "description", null)
      filter      = exclusions.value["filter"]
    }
  }
}

resource "google_project_iam_audit_config" "k8s_data_access_logs" {
  count   = var.enable_gke_data_access_logs ? length(local.projects) : 0
  project = local.projects[count.index]
  service = "container.googleapis.com"

  audit_log_config {
    log_type         = "ADMIN_READ"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
  audit_log_config {
    log_type         = "DATA_READ"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
  audit_log_config {
    log_type         = "DATA_WRITE"
    exempted_members = var.gke_data_access_logs_exempted_members
  }
}

resource "google_pubsub_topic_iam_binding" "wiz_audit_logs" {
  count = var.iam_policy_type == "BINDING" ? 1 : 0

  project = local.project_id

  members = local.writer_identities
  role    = "roles/pubsub.publisher"
  topic   = google_pubsub_topic.wiz_audit_logs.name
}

resource "google_pubsub_topic_iam_member" "wiz_audit_logs" {
  count = var.iam_policy_type == "MEMBER" ? length(local.writer_identities) : 0

  project = local.project_id

  member = local.writer_identities[count.index]
  role   = "roles/pubsub.publisher"
  topic  = google_pubsub_topic.wiz_audit_logs.name
}
