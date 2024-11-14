variable "enable_gke_data_access_logs" {
  type        = bool
  description = "A boolean representing whether to enable GKE Data Access logging"
  default     = false
}

variable "enable_wiz_defend_log_sources" {
  type        = bool
  description = "A boolean representing whether Wiz Defend log sources should be enabled"
  default     = false
}

variable "gke_data_access_logs_exempted_members" {
  type        = list(string)
  description = "A list of strings representing identities which should be exempt from GKE Data Access logging"
  default     = []
}

variable "iam_policy_type" {
  type        = string
  default     = "BINDING"
  description = "Specify the IAM policy type to be used. Can only be BINDING or MEMBER."
  validation {
    condition     = contains(["BINDING", "MEMBER"], var.iam_policy_type)
    error_message = "The iam_policy_type must be either BINDING or MEMBER."
  }
}

variable "integration_type" {
  type        = string
  default     = "ORGANIZATION"
  description = "Specify the integration type. Can only be FOLDER, ORGANIZATION or PROJECT. Project-level integrations only apply to a single Google Cloud project. Folder-level integrations can be used to monitor a list of folders, or a list of projects using `monitored_folders` and `monitored_projects`. Organization-level integrations can be used to monitor an entire organization, a list of folders, or a list of projects using `monitored_folders` and `monitored_projects`. Defaults to ORGANIZATION"
  validation {
    condition     = contains(["FOLDER", "ORGANIZATION", "PROJECT"], var.integration_type)
    error_message = "The integration_type must be either FOLDER, ORGANIZATION or PROJECT."
  }
}

variable "log_sink_exclusions" {
  type = list(map(any))
  default = [
    {
      name   = "exclude-non-interesting-events"
      filter = <<EOT
protoPayload.methodName!~"^io\.k8s\..*\.(approve|bind|create|delete|deletecollection|escalate|impersonate|patch|post|proxy|put|sign|update|get|list)$" AND protoPayload.methodName!~"^io\.k8s\..*secrets\.watch$" AND resource.type="k8s_cluster"
EOT
    },
    {
      name   = "exclude-control-plane-1"
      filter = <<EOT
protoPayload.authenticationInfo.principalEmail=~"^system\:" AND protoPayload.authenticationInfo.principalEmail!="^system\:anonymous" AND protoPayload.authenticationInfo.principalEmail!~"^system\:serviceaccount"
EOT
    },
    {
      name   = "exclude-control-plane-2"
      filter = <<EOT
((protoPayload.authenticationInfo.principalEmail="system\:serviceaccount\:kube-system\:namespace-controller" AND protoPayload.methodName=~"^io\..*\.deletecollection$") OR (protoPayload.authenticationInfo.principalEmail="system\:serviceaccount\:kube-system\:generic-garbage-collector" AND protoPayload.methodName=~"^io\..*\.delete$")) AND resource.type="k8s_cluster"
EOT
    },
    {
      name   = "exclude-non-interesting-principals"
      filter = <<EOT
protoPayload.authenticationInfo.principalEmail=~".*(-operator|\:operator|\:rancher|\:cert-manager-cainjector|\:prometheus-server|\:domino-platform|\:custom-metrics-stackdriver-adapter|\:composer-system|\:observe-metrics|\:rbac-manager)$"
EOT
    },
    {
      name   = "exclude-non-interesting-resources"
      filter = <<EOT
(protoPayload.methodName=~"^io\.k8s\..*(leases|selfsubjectrulesreviews|subjectaccessreviews|tokenreviews|selfsubjectaccessreviews).*" OR protoPayload.methodName=~"^io\.k8s\..*\.events\.patch$" OR protoPayload.methodName=~"^io\.k8s\..*\.services\.proxy\..*" OR protoPayload.methodName=~"^io\.k8s\..*\.status\.(patch|update)$") AND resource.type="k8s_cluster"
EOT
    }
  ]
}

variable "wiz_defend_additional_log_sink_exclusions" {
  type = list(map(any))
  default = [
    {
      name   = "exclude-noisy-data-events-services"
      filter = <<EOT
protoPayload.authorizationInfo.permissionType=~"(DATA_READ|DATA_WRITE)" AND protoPayload.serviceName=~"(bigtable.googleapis.com|spanner.googleapis.com|monitoring.googleapis.com|dataproc.googleapis.com)"
EOT
    },
  ]
}

variable "log_sink_filter" {
  type        = string
  description = "The inclusion filter to use when creating Activity Log sinks"
  default     = <<EOT
log_id("cloudaudit.googleapis.com/activity") OR protoPayload.serviceName="k8s.io" OR protoPayload.serviceName="login.googleapis.com" OR protoPayload.methodName="GenerateAccessToken"
EOT
}

variable "message_retention_duration" {
  type        = string
  description = "The the minimum duration to retain cloud event messages in pub/sub"
  default     = "86400s"
}

variable "monitored_folders" {
  type        = list(string)
  default     = []
  description = "A list of folders in which to deploy Cloud Event log sinks.  For organization-level integration, if `monitored_folders` and `monitored_projects` are empty, organization-level monitoring is assumed."
}

variable "monitored_projects" {
  type        = list(string)
  description = "A list of projects in which to deploy Cloud Event log sinks.  For organization-level integration, if `monitored_folders` and `monitored_projects` are empty, organization-level monitoring is assumed."
  default     = []
}

variable "org_id" {
  type        = string
  default     = ""
  description = "The organization ID, required if integration_type is set to ORGANIZATION"
}

variable "pubsub_subscription_name" {
  type        = string
  default     = "wiz-export-audit-logs-sub"
  description = "The name of the pub/sub subscription where cloud event logs will be queued"
}

variable "pubsub_topic_name" {
  type        = string
  default     = "wiz-export-audit-logs"
  description = "The name of the pub/sub topic where cloud event logs will be sent"
}

variable "project_id" {
  type        = string
  default     = ""
  description = "Specify the project ID if it's not explcitly set in the provider configuration or if you wish to override the provider's project ID"
  validation {
    condition     = can(regex("(^[a-z][a-z0-9-]{4,28}[a-z0-9]$|^$)", var.project_id))
    error_message = "The project_id variable must be a valid GCP project ID. It must be 6 to 30 lowercase ASCII letters, digits, or hyphens. It must start with a letter. Trailing hyphens are prohibited."
  }
}

variable "project_service_wait_time" {
  type        = string
  default     = "10s"
  description = "Amount of time to wait after enabling the required Google Cloud APIs"
}

variable "required_apis" {
  type = map(any)
  default = {
    cloudresourcemanager = "cloudresourcemanager.googleapis.com"
    iam                  = "iam.googleapis.com"
    pubsub               = "pubsub.googleapis.com"
    serviceusage         = "serviceusage.googleapis.com"
  }
}

variable "service_account_email" {
  type        = string
  description = "The email address of the Wiz service account used to fetch activity logs"
}

variable "wiz_defend_log_sink_filter" {
  type        = string
  description = "A string containing log sink inclusion filter for Wiz Defend log sources"
  default     = <<EOT
log_id("cloudaudit.googleapis.com/activity") OR protoPayload.serviceName="k8s.io" OR log_id("cloudaudit.googleapis.com/data_access")
EOT
}
