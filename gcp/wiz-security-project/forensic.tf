resource "google_project_iam_custom_role" "wiz_security_role_forensic_ext" {
  count   = var.forensic ? 1 : 0
  project = var.project_id
  role_id = var.wiz_security_role_forensic_ext_name
  title   = var.wiz_security_role_forensic_ext_name
  permissions = [
    "compute.disks.createSnapshot",
    "compute.snapshots.create",
    "compute.snapshots.setLabels",
    "compute.snapshots.useReadOnly",
    "compute.snapshots.delete"
  ]
}

resource "google_project_iam_member" "wiz_worker_security_role_forensic_ext" {
  count      = var.forensic ? 1 : 0
  project    = var.project_id
  role       = google_project_iam_custom_role.wiz_security_role_forensic_ext[0].name
  member     = "serviceAccount:${local.disk_analysis_service_account_id}"
  depends_on = [google_project_iam_custom_role.wiz_security_role_forensic_ext]
  condition {
    title       = "Wiz Limited Condition"
    description = "Apply Forensic role permissions to only snapshots ending with \"-wiz\""
    expression  = "(resource.type == \"compute.googleapis.com/Snapshot\" && resource.name.endsWith(\"-wiz\")) || (resource.type == \"compute.googleapis.com/Disk\")"
  }
}
