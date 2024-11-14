locals {
  use_managed_identity             = var.wiz_managed_identity_external_id != ""
  wiz_managed                      = var.worker_service_account_id == ""
  fetcher_service_account_id       = local.use_managed_identity ? var.wiz_managed_identity_external_id : google_service_account.wiz-service-account[0].email
  disk_analysis_service_account_id = local.wiz_managed ? local.fetcher_service_account_id : var.worker_service_account_id

  fetcher_roles_standard = {
    wiz_security_role               = google_project_iam_custom_role.wiz_security_role.id
    viewer                          = "roles/viewer"
    browser                         = "roles/browser"
    iam_securityReviewer            = "roles/iam.securityReviewer"
    cloudasset_viewer               = "roles/cloudasset.viewer"
    serviceusage_serviceUsageViewer = "roles/serviceusage.serviceUsageViewer"
  }

  fetcher_roles_least_privilege = {
    wiz_security_role = google_project_iam_custom_role.wiz_security_role.id
  }

  fetcher_roles = var.least_privilege_policy ? local.fetcher_roles_least_privilege : local.fetcher_roles_standard
  disk_analysis_roles = {
    cloudkms_cryptoKeyEncrypterDecrypter = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  }
}
