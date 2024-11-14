resource "google_organization_iam_custom_role" "wiz_security_role_registry_scanning_ext" {
  org_id      = var.org_id
  role_id     = var.wiz_security_role_registry_scanning_ext_name
  title       = var.wiz_security_role_registry_scanning_ext_name
  permissions = local.REGISTRY_SCANNING_ROLE_PERMISSIONS
}

resource "google_organization_iam_member" "wiz_worker_security_role_registry_scanning_ext" {
  org_id     = var.org_id
  role       = google_organization_iam_custom_role.wiz_security_role_registry_scanning_ext.name
  member     = "serviceAccount:${local.disk_analysis_service_account_id}"
  depends_on = [google_organization_iam_custom_role.wiz_security_role_registry_scanning_ext]
}

locals {
  REGISTRY_SCANNING_ROLE_PERMISSIONS = [
    "artifactregistry.repositories.downloadArtifacts",
    "storage.objects.get"
  ]
}