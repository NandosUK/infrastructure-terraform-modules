//region Custom roles

resource "google_organization_iam_custom_role" "wiz_security_role_disk_analysis_ext" {
  role_id     = var.wiz_security_role_disk_analysis_ext_name
  org_id      = var.org_id
  title       = var.wiz_security_role_disk_analysis_ext_name
  permissions = local.DISK_ANALYSIS_ROLE_PERMISSIONS
}

//endregion Custom roles

resource "google_organization_iam_member" "disk_analysis_roles" {
  for_each = local.disk_analysis_roles
  org_id   = var.org_id
  role     = each.value
  member   = "serviceAccount:${local.disk_analysis_service_account_id}"
}

resource "google_organization_iam_member" "wiz_da_role" {
  org_id     = var.org_id
  role       = google_organization_iam_custom_role.wiz_security_role_disk_analysis_ext.name
  member     = "serviceAccount:${local.disk_analysis_service_account_id}"
  depends_on = [google_organization_iam_custom_role.wiz_security_role_disk_analysis_ext]
}

locals {
  DISK_ANALYSIS_ROLE_PERMISSIONS = [
    "compute.disks.get",
    "compute.disks.useReadOnly",
    "compute.globalOperations.get",
    "compute.images.get",
    "compute.images.getIamPolicy",
    "compute.images.list",
    "compute.images.setIamPolicy",
    "compute.images.useReadOnly",
    "compute.snapshots.get",
    "compute.snapshots.list"
  ]
}