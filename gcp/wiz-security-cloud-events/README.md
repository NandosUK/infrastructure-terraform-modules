<!-- BEGIN_TF_DOCS -->
# wiz-gcp-cloud-events-terraform-module

A Terraform module to integrate Google Cloud Activity Logs with Wiz.

## External Documentation

The Terraform Provider for Google Cloud sometimes doesn't follow documentation conventions for Terraform resources. Thus, links to the pertinent documentation are provided below.

- [google\_organization\_iam\_audit\_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_organization_iam#google_organization_iam_audit_config)
- [google\_folder\_iam\_audit\_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_folder_iam#google_folder_iam_audit_config)
- [google\_project\_iam\_audit\_config](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam#google_project_iam_audit_config)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |
| google | >= 4.1 |
| time | >= 0.10.0 |

## Providers

| Name | Version |
|------|---------|
| google | >= 4.1 |
| random | n/a |
| time | >= 0.10.0 |

## Resources

| Name | Type |
|------|------|
| [google_folder_iam_audit_config.k8s_data_access_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/folder_iam_audit_config) | resource |
| [google_logging_folder_sink.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_folder_sink) | resource |
| [google_logging_organization_sink.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_organization_sink) | resource |
| [google_logging_project_sink.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/logging_project_sink) | resource |
| [google_organization_iam_audit_config.k8s_data_access_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/organization_iam_audit_config) | resource |
| [google_project_iam_audit_config.k8s_data_access_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_audit_config) | resource |
| [google_project_service.required_apis](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [google_pubsub_subscription.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription) | resource |
| [google_pubsub_subscription_iam_binding.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_binding) | resource |
| [google_pubsub_subscription_iam_member.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_subscription_iam_member) | resource |
| [google_pubsub_topic.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic) | resource |
| [google_pubsub_topic_iam_binding.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_binding) | resource |
| [google_pubsub_topic_iam_member.wiz_audit_logs](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/pubsub_topic_iam_member) | resource |
| [random_id.uniq](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [time_sleep.required_apis](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [google_project.selected](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/project) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| service\_account\_email | The email address of the Wiz service account used to fetch activity logs | `string` | n/a | yes |
| enable\_gke\_data\_access\_logs | A boolean representing whether to enable GKE Data Access logging | `bool` | `false` | no |
| enable\_wiz\_defend\_log\_sources | A boolean representing whether Wiz Defend log sources should be enabled | `bool` | `false` | no |
| gke\_data\_access\_logs\_exempted\_members | A list of strings representing identities which should be exempt from GKE Data Access logging | `list(string)` | `[]` | no |
| iam\_policy\_type | Specify the IAM policy type to be used. Can only be BINDING or MEMBER. | `string` | `"BINDING"` | no |
| integration\_type | Specify the integration type. Can only be FOLDER, ORGANIZATION or PROJECT. Project-level integrations only apply to a single Google Cloud project. Folder-level integrations can be used to monitor a list of folders, or a list of projects using `monitored_folders` and `monitored_projects`. Organization-level integrations can be used to monitor an entire organization, a list of folders, or a list of projects using `monitored_folders` and `monitored_projects`. Defaults to ORGANIZATION | `string` | `"ORGANIZATION"` | no |
| log\_sink\_exclusions | n/a | `list(map(any))` | <pre>[<br/>  {<br/>    "filter": "protoPayload.methodName!~\"^io\\.k8s\\..*\\.(approve|bind|create|delete|deletecollection|escalate|impersonate|patch|post|proxy|put|sign|update|get|list)$\" AND protoPayload.methodName!~\"^io\\.k8s\\..*secrets\\.watch$\" AND resource.type=\"k8s_cluster\"\n",<br/>    "name": "exclude-non-interesting-events"<br/>  },<br/>  {<br/>    "filter": "protoPayload.authenticationInfo.principalEmail=~\"^system\\:\" AND protoPayload.authenticationInfo.principalEmail!=\"^system\\:anonymous\" AND protoPayload.authenticationInfo.principalEmail!~\"^system\\:serviceaccount\"\n",<br/>    "name": "exclude-control-plane-1"<br/>  },<br/>  {<br/>    "filter": "((protoPayload.authenticationInfo.principalEmail=\"system\\:serviceaccount\\:kube-system\\:namespace-controller\" AND protoPayload.methodName=~\"^io\\..*\\.deletecollection$\") OR (protoPayload.authenticationInfo.principalEmail=\"system\\:serviceaccount\\:kube-system\\:generic-garbage-collector\" AND protoPayload.methodName=~\"^io\\..*\\.delete$\")) AND resource.type=\"k8s_cluster\"\n",<br/>    "name": "exclude-control-plane-2"<br/>  },<br/>  {<br/>    "filter": "protoPayload.authenticationInfo.principalEmail=~\".*(-operator|\\:operator|\\:rancher|\\:cert-manager-cainjector|\\:prometheus-server|\\:domino-platform|\\:custom-metrics-stackdriver-adapter|\\:composer-system|\\:observe-metrics|\\:rbac-manager)$\"\n",<br/>    "name": "exclude-non-interesting-principals"<br/>  },<br/>  {<br/>    "filter": "(protoPayload.methodName=~\"^io\\.k8s\\..*(leases|selfsubjectrulesreviews|subjectaccessreviews|tokenreviews|selfsubjectaccessreviews).*\" OR protoPayload.methodName=~\"^io\\.k8s\\..*\\.events\\.patch$\" OR protoPayload.methodName=~\"^io\\.k8s\\..*\\.services\\.proxy\\..*\" OR protoPayload.methodName=~\"^io\\.k8s\\..*\\.status\\.(patch|update)$\") AND resource.type=\"k8s_cluster\"\n",<br/>    "name": "exclude-non-interesting-resources"<br/>  }<br/>]</pre> | no |
| log\_sink\_filter | The inclusion filter to use when creating Activity Log sinks | `string` | `"log_id(\"cloudaudit.googleapis.com/activity\") OR protoPayload.serviceName=\"k8s.io\" OR protoPayload.serviceName=\"login.googleapis.com\" OR protoPayload.methodName=\"GenerateAccessToken\"\n"` | no |
| message\_retention\_duration | The the minimum duration to retain cloud event messages in pub/sub | `string` | `"86400s"` | no |
| monitored\_folders | A list of folders in which to deploy Cloud Event log sinks.  For organization-level integration, if `monitored_folders` and `monitored_projects` are empty, organization-level monitoring is assumed. | `list(string)` | `[]` | no |
| monitored\_projects | A list of projects in which to deploy Cloud Event log sinks.  For organization-level integration, if `monitored_folders` and `monitored_projects` are empty, organization-level monitoring is assumed. | `list(string)` | `[]` | no |
| org\_id | The organization ID, required if integration\_type is set to ORGANIZATION | `string` | `""` | no |
| project\_id | Specify the project ID if it's not explcitly set in the provider configuration or if you wish to override the provider's project ID | `string` | `""` | no |
| project\_service\_wait\_time | Amount of time to wait after enabling the required Google Cloud APIs | `string` | `"10s"` | no |
| pubsub\_subscription\_name | The name of the pub/sub subscription where cloud event logs will be queued | `string` | `"wiz-export-audit-logs-sub"` | no |
| pubsub\_topic\_name | The name of the pub/sub topic where cloud event logs will be sent | `string` | `"wiz-export-audit-logs"` | no |
| required\_apis | n/a | `map(any)` | <pre>{<br/>  "cloudresourcemanager": "cloudresourcemanager.googleapis.com",<br/>  "iam": "iam.googleapis.com",<br/>  "pubsub": "pubsub.googleapis.com",<br/>  "serviceusage": "serviceusage.googleapis.com"<br/>}</pre> | no |
| wiz\_defend\_additional\_log\_sink\_exclusions | n/a | `list(map(any))` | <pre>[<br/>  {<br/>    "filter": "protoPayload.authorizationInfo.permissionType=~\"(DATA_READ|DATA_WRITE)\" AND protoPayload.serviceName=~\"(bigtable.googleapis.com|spanner.googleapis.com|monitoring.googleapis.com|dataproc.googleapis.com)\"\n",<br/>    "name": "exclude-noisy-data-events-services"<br/>  }<br/>]</pre> | no |
| wiz\_defend\_log\_sink\_filter | A string containing log sink inclusion filter for Wiz Defend log sources | `string` | `"log_id(\"cloudaudit.googleapis.com/activity\") OR protoPayload.serviceName=\"k8s.io\" OR log_id(\"cloudaudit.googleapis.com/data_access\")\n"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cloud\_events\_subscription\_id | n/a |
| cloud\_events\_topic | n/a |
<!-- END_TF_DOCS -->