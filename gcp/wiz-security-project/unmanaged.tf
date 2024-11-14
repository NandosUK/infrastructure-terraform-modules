resource "google_service_account" "wiz-service-account" {
  count        = local.use_managed_identity ? 0 : 1
  account_id   = var.wiz_service_account_name
  display_name = var.wiz_service_account_name
  project      = var.project_id
  depends_on   = [time_sleep.required_apis]
}

resource "google_project_service" "required_apis" {
  for_each = local.use_managed_identity ? {} : var.required_apis
  project  = var.project_id
  service  = each.value

  disable_on_destroy = false
}

resource "time_sleep" "required_apis" {
  count           = local.use_managed_identity ? 0 : 1
  create_duration = var.project_service_wait_time
  depends_on = [
    google_project_service.required_apis,
  ]
}

resource "google_service_account_iam_binding" "fetcher_self_impersonation_roles" {
  count              = local.use_managed_identity ? 0 : 1
  service_account_id = local.fetcher_service_account_id
  role               = "roles/iam.serviceAccountTokenCreator"
  members            = ["serviceAccount:${local.fetcher_service_account_id}"]
}
