resource "google_project_iam_custom_role" "wiz_security_role_data_scanning_ext" {
  count       = var.data_scanning ? 1 : 0
  project     = var.project_id
  role_id     = var.wiz_security_role_data_scanning_ext_name
  title       = var.wiz_security_role_data_scanning_ext_name
  permissions = local.DATA_SCANNING_ROLE_PERMISSIONS
}

resource "google_project_iam_member" "wiz_worker_security_role_data_scanning_ext" {
  count      = var.data_scanning ? 1 : 0
  project    = var.project_id
  role       = google_project_iam_custom_role.wiz_security_role_data_scanning_ext[0].name
  member     = "serviceAccount:${local.disk_analysis_service_account_id}"
  depends_on = [google_project_iam_custom_role.wiz_security_role_data_scanning_ext]
}

locals {
  DATA_SCANNING_ROLE_PERMISSIONS = [
    "bigquery.jobs.create",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.list",
    "cloudsql.backupRuns.create",
    "cloudsql.backupRuns.delete",
    "cloudsql.backupRuns.get",
    "cloudsql.backupRuns.list",
    "cloudsql.instances.get",
    "cloudsql.instances.list",
    "storage.objects.get",
    "storage.objects.list"
  ]
}