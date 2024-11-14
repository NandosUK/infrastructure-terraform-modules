module "wiz_gcp_cloud_events" {
  count  = var.cloud_events ? 1 : 0
  source = "https://s3-us-east-2.amazonaws.com/wizio-public/deployment-v2/gcp/wiz-gcp-cloud-events-terraform-module.zip"

  integration_type      = "ORGANIZATION"
  org_id                = var.org_id
  project_id            = var.cloud_events_project_id
  service_account_email = local.fetcher_service_account_id
  iam_policy_type       = var.cloud_events_iam_policy_type

  monitored_folders  = var.cloud_events_folders
  monitored_projects = var.cloud_events_projects

  enable_gke_data_access_logs           = var.cloud_events_enable_gke_data_access_logs
  gke_data_access_logs_exempted_members = var.cloud_events_gke_data_access_logs_exempted_members
}
