resource "google_organization_iam_custom_role" "wiz_security_role_data_scanning_ext" {
  count       = var.data_scanning ? 1 : 0
  org_id      = var.org_id
  role_id     = var.wiz_security_role_data_scanning_ext_name
  title       = var.wiz_security_role_data_scanning_ext_name
  permissions = local.DATA_SCANNING_ROLE_PERMISSIONS
}

resource "google_organization_iam_member" "wiz_worker_security_role_data_scanning_ext" {
  count      = var.data_scanning ? 1 : 0
  org_id     = var.org_id
  role       = google_organization_iam_custom_role.wiz_security_role_data_scanning_ext[0].name
  member     = "serviceAccount:${local.disk_analysis_service_account_id}"
  depends_on = [google_organization_iam_custom_role.wiz_security_role_data_scanning_ext]
}

resource "google_organization_iam_member" "wiz_worker_category_reader" {
  count  = var.data_scanning ? 1 : 0
  org_id = var.org_id
  role   = "roles/datacatalog.categoryFineGrainedReader"
  member = "serviceAccount:${local.disk_analysis_service_account_id}"
}

locals {
  DATA_SCANNING_ROLE_PERMISSIONS = [
    "bigquery.jobs.create",
    "bigquery.tables.get",
    "bigquery.tables.getData",
    "bigquery.tables.list",
    "bigquery.transfers.get",
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