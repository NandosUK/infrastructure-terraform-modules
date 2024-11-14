variable "org_id" {
  type = string
}

variable "wiz_managed_identity_external_id" {
  type    = string
  default = ""
}

variable "worker_service_account_id" {
  type    = string
  default = ""
}

variable "wiz_security_role_name" {
  type    = string
  default = "wiz_security_role"
}

variable "wiz_security_role_disk_analysis_ext_name" {
  type    = string
  default = "wiz_security_role_disk_analysis_ext"
}

variable "cloud_events" {
  type        = bool
  default     = false
  description = "Set to `true` to deploy Cloud Event monitoring infrastructure."
}

variable "cloud_events_project_id" {
  type    = string
  default = ""
}

variable "cloud_events_enable_gke_data_access_logs" {
  type        = bool
  description = "A boolean representing whether to enable GKE Data Access logging for Cloud Events"
  default     = false
}

variable "cloud_events_folders" {
  type        = list(string)
  default     = []
  description = "A list of folders in which to deploy Cloud Event log sinks.  If `cloud_events_folders` and `cloud_events_projects` are empty, organization-level monitoring is assumed."
}

variable "cloud_events_gke_data_access_logs_exempted_members" {
  type        = list(string)
  description = "A list of strings representing identities which should be exempt from GKE Data Access logging for Cloud Events"
  default     = []
}

variable "cloud_events_iam_policy_type" {
  type        = string
  default     = "BINDING"
  description = "Specify the IAM policy type to be used for Cloud Events IAM permissions. Can only be BINDING or MEMBER."
  validation {
    condition     = contains(["BINDING", "MEMBER"], var.cloud_events_iam_policy_type)
    error_message = "The iam_policy_type must be either BINDING or MEMBER."
  }
}

variable "cloud_events_projects" {
  type        = list(string)
  default     = []
  description = "A list of projects in which to deploy Cloud Event log sinks.  If `cloud_events_folders` and `cloud_events_projects` are empty, organization-level monitoring is assumed."
}

variable "data_scanning" {
  type    = bool
  default = false
}

variable "wiz_security_role_data_scanning_ext_name" {
  type    = string
  default = "wiz_security_role_data_scanning_ext"
}

variable "serverless_scanning" {
  type    = bool
  default = false
}

variable "wiz_security_role_serverless_scanning_ext_name" {
  type    = string
  default = "wiz_security_role_serverless_scanning_ext"
}

variable "forensic" {
  type    = bool
  default = false
}

variable "wiz_security_role_forensic_ext_name" {
  type    = string
  default = "wiz_security_role_forensic_ext"
}

variable "least_privilege_policy" {
  type    = bool
  default = false
}

variable "wiz_security_role_registry_scanning_ext_name" {
  type    = string
  default = "wiz_security_role_registry_scanning_ext"
}
