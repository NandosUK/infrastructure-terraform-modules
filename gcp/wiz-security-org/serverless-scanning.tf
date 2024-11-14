resource "google_organization_iam_custom_role" "wiz_security_role_serverless_scanning_ext" {
  count       = var.serverless_scanning ? 1 : 0
  org_id      = var.org_id
  role_id     = var.wiz_security_role_serverless_scanning_ext_name
  title       = var.wiz_security_role_serverless_scanning_ext_name
  permissions = local.SERVERLESS_SCANNING_ROLE_PERMISSIONS
}

resource "google_organization_iam_member" "wiz_worker_security_role_serverless_scanning_ext" {
  count      = var.serverless_scanning ? 1 : 0
  org_id     = var.org_id
  role       = google_organization_iam_custom_role.wiz_security_role_serverless_scanning_ext[0].name
  member     = "serviceAccount:${local.disk_analysis_service_account_id}"
  depends_on = [google_organization_iam_custom_role.wiz_security_role_serverless_scanning_ext]
}

locals {
  SERVERLESS_SCANNING_ROLE_PERMISSIONS = [
    "artifactregistry.repositories.downloadArtifacts",
    "artifactregistry.repositories.get",
    "cloudfunctions.functions.get",
    "cloudfunctions.functions.sourceCodeGet",
    "run.revisions.get",
    "storage.objects.get",
    "storage.objects.list"
  ]
}