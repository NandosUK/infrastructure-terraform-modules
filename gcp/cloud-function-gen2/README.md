# Terraform Google Cloud Function gen2

## Overview

This updated Terraform module provides a comprehensive set of reusable configurations for deploying services to Google Cloud Function 2nd generation, including its deployment, scheduling, IAM permissions, Cloud Build triggers, and alerting.

## Branching Strategy

[Details about the branching strategy](https://chat.openai.com/cloud-cloudbuild-trigger/README.md)

## Features

### Internal modules

- **google_storage_bucket_object Resource:** This resource defines a Cloud Storage bucket object. It specifies the name, bucket, and source of the object.

- **google_cloudfunctions2_function Resource:** This resource defines a Google Cloud Functions 2.0 function. It includes configurations for function behavior, environment variables, event triggers, and build settings. Conditional blocks are used to handle different event types and configurations.

- **google_cloud_scheduler_job Resource:** This resource defines a Google Cloud Scheduler job. It schedules the execution of a Cloud Function using HTTP requests, specifying details like schedule, time zone, and retry settings.

- **google_cloud_run_service_iam_member Resource:** This resource grants IAM permissions to invoke the Cloud Function. It is conditional based on the `var.public` flag and grants the `run.invoker` role to `allUsers` if `var.public` is true. Gen 2 functions are fronted by Cloud Run, so invocation is authorised there rather than via the gen 1 `cloudfunctions.invoker` role.

- **module "trigger_provision":** This module configures a Cloud Build trigger for provisioning the Cloud Function. It includes settings for the trigger's name, description, source, and environment variables.

- **module "cloud_function_alerts":** This module sets up alerts and notifications for the Cloud Function. It includes configurations for alert thresholds, duration, and notification channels.

## Runtime

Terraform owns the runtime. `var.function_runtime` (or, when unset, `var.node_version` /
`var.go_version` depending on `var.function_type`) is used for the function's `build_config`,
exposed as the `runtime` output, and passed to the provisioning trigger as the `_RUNTIME`
substitution.

Have each `cloudbuild.yaml` deploy with `--runtime ${_RUNTIME}` so deploys re-assert Terraform's
value instead of competing with it. `runtime` is deliberately left out of the resource's
`ignore_changes`, so a bump applies on the next `terraform apply` rather than waiting for each
function's next deploy.

Defaults track the latest GA gen 2 runtimes (`nodejs24`, `go127`). `nodejs26` is preview.

## Configuration ownership

Terraform owns `service_config`. Only `build_config` fields the deploy legitimately replaces
(source, entry point, build env vars, update policies) are in `ignore_changes` — memory, timeout,
instance counts, service account, environment variables, secrets, concurrency, ingress and VPC
egress are all reconciled on every `apply`.

That makes the deploy command narrow. A `cloudbuild.yaml` should pass source, runtime, entry point
and trigger, and nothing else:

```bash
gcloud functions deploy ${_FUNCTION_NAME} \
  --gen2 --region ${_LOCATION} --runtime ${_RUNTIME} \
  --source gs://${_SOURCE_BUCKET_NAME}/${_ZIP_FILE_NAME}.zip \
  --entry-point ${_ENTRY_POINT} --trigger-topic ${_TRIGGER_TOPIC}
```

A deploy that also passes `--set-env-vars`, `--update-secrets`, `--memory`, `--timeout` or
`--min-instances` will fight Terraform: the next `apply` reverts what the deploy set, and the next
deploy sets it back again. Move that configuration into the module's variables.

### Migrating a repo that configures via gcloud flags

`--set-env-vars` replaces the whole set and omitting it leaves the running values untouched, so the
transition has no window where config flaps:

1. Capture live state per function *per environment* with
   `gcloud functions describe <fn> --format=json` and generate the Terraform from it. Do not
   transcribe by hand — that is where silent production changes get introduced.
2. Apply with the flags still in the `cloudbuild.yaml`, and confirm the plan is empty.
3. Remove the flags from the `cloudbuild.yaml`.

## Secrets

`var.secret_keys` is shorthand for the case where the environment variable name, the secret name and
the project all coincide:

```hcl
secret_keys = ["CONSENT_API_TOKEN"]
```

Use `var.secret_environment_variables` when any of those differ:

```hcl
secret_environment_variables = [
  { key = "AUTH_KEY", secret = "DISABLE_EXPIRED_JOBS_AUTH_KEY" },
  { key = "OKTA_API_KEY", secret = "PROFILE_API_OKTA_API_KEY", version = "3" },
  { key = "CROSS_PROJECT", secret = "SHARED_TOKEN", project_id = "other-project" },
]
```

`secret` defaults to `key`, `version` to `latest`, `project_id` to `var.project_id`. The two lists
are merged by environment variable name, and an explicit entry wins over a `secret_keys` one.

## Guards

Two `check` blocks warn at plan time when alert configuration is silently ignored — when
`notification_channels` or `threshold_value` are set but `alert_config` is not, which otherwise
produces an alert policy that pages nobody. They are warnings, not errors, so existing callers keep
applying. (`check` requires Terraform >= 1.5.)

A precondition errors when `event_trigger` is set but `event_type` is not one of `PUBSUB`,
`STORAGE` or `EVENTARC`, since the trigger blocks are selected by `event_type` and the function
would otherwise be created with no trigger at all.

## Specific Variables

- `var.function_name`: This variable holds the name of the Google Cloud Function.
- `var.function_path`: It defines the path to the function's source code within the repository.
- `var.bucket_functions`: This variable specifies the name of the Google Cloud Storage bucket where function source code is stored.
- `var.function_source_archive_object`: It represents the name of the Cloud Storage object containing the function's source code archive.
- `var.max_instance_count`: This variable defines the maximum number of instances for the Google Cloud Function.
- `var.min_instance_count`: It sets the minimum number of instances for the Google Cloud Function.
- `var.available_memory_mb`: This variable specifies the amount of memory allocated to each function instance.
- `var.timeout_seconds`: It determines the maximum execution time in seconds for the function.
- `var.language_config`: This variable is a map that defines language-specific configuration for the function, including source code archives, entry points, and runtimes.
- `var.function_type`: It specifies the programming language used for the function (e.g., "node," "go").
- `var.event_type`: This variable defines the type of event trigger for the function (e.g., "PUBSUB," "STORAGE," "SCHEDULER").
- `var.schedule`: This variable holds scheduling information for the function, including cron schedules and time zones.
- `var.public`: It determines whether the Cloud Function is publicly accessible, and if true, grants permissions to "allUsers" to invoke the function.
- `var.cloudbuild_yaml_suffix`: Suffix inserted into the Cloud Build config filename, as `cloudbuild<suffix>.yaml`. Defaults to `""`, i.e. `cloudbuild.yaml`.
- `var.function_runtime`: Overrides the language default runtime for this function.
- `var.secret_environment_variables`: Secrets mounted as env vars where the env var name, secret name, version or project differ from `var.secret_keys`' assumptions.
- `var.max_instance_request_concurrency`: Maximum concurrent requests per instance.
- `var.ingress_settings`: `ALLOW_ALL`, `ALLOW_INTERNAL_ONLY` or `ALLOW_INTERNAL_AND_GCLB`.
- `var.vpc_connector` / `var.vpc_connector_egress_settings`: Serverless VPC Access connector and which egress routes through it.
- `var.labels`: Labels applied to the function.
- `var.node_version`: Default runtime for `function_type = "node"` when `var.function_runtime` is unset.
- `var.go_version`: Default runtime for `function_type = "go"` when `var.function_runtime` is unset.

## Multiple functions from one source directory

By default the trigger looks for `cloudbuild.yaml` in the function's source directory. Set
`var.cloudbuild_yaml_suffix` when several functions share a directory and each needs its own build
config:

```hcl
module "cloud_function" {
  for_each = toset(["collector", "pubsub"])

  source                 = "github.com/NandosUK/infrastructure-terraform-modules//gcp/cloud-function-gen2"
  function_name          = "${local.service_name}-${each.key}"
  function_path          = "services/${local.service_name}"
  cloudbuild_yaml_suffix = "-${each.key}"
  # ...
}
```

That resolves to `services/<service>/cloudbuild-collector.yaml` and
`services/<service>/cloudbuild-pubsub.yaml`. The suffix applies whether or not `function_path` is
set. `included_files` is unaffected — it still watches the whole directory, so a change to shared
code fires every function's trigger.

## Retained-for-compatibility variables

`var.branching_strategy` and `var.notification_channels` are declared but unused. Both now have
defaults, so new call sites can omit them; they are kept rather than removed because existing
callers pass them.

- **`branching_strategy`** — the [cloud-cloudbuild-trigger](../cloud-cloudbuild-trigger) submodule
  derives push branches from its own per-environment defaults keyed off `var.environment`.
- **`notification_channels`** — alert routing comes from `var.alert_config.notification_channels`.
  This is deliberately *not* wired up as a fallback: callers that set the top-level variable while
  leaving `alert_config` at its default currently get alert policies with no notification channels,
  and silently switching their alerts on would not be backwards compatible.

## Usage

Refer to the example Terraform script in the example folder for a demonstration on how to use this updated module.

Example of use:

[test/gcp/cloud-function-gen2.tf](https://chat.openai.com/test/gcp/cloud-function-gen2.tf)

## Contribution

Contributions are welcome! Please open an issue or submit a pull request.

## License

This module is released under the MIT License. Check the LICENSE file for more details.---
