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

- **google_cloudfunctions_function_iam_member Resource:** This resource grants IAM permissions to invoke the Cloud Function. It is conditional based on the `var.public` flag and grants the `cloudfunctions.invoker` role to `allUsers` if `var.public` is true.

- **module "trigger_provision":** This module configures a Cloud Build trigger for provisioning the Cloud Function. It includes settings for the trigger's name, description, source, and environment variables.

- **module "cloud_function_alerts":** This module sets up alerts and notifications for the Cloud Function. It includes configurations for alert thresholds, duration, and notification channels.

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

## Usage

Refer to the example Terraform script in the example folder for a demonstration on how to use this updated module.

Example of use:

[test/gcp/cloud-function-gen2.tf](https://chat.openai.com/test/gcp/cloud-function-gen2.tf)

## Contribution

Contributions are welcome! Please open an issue or submit a pull request.

## License

This module is released under the MIT License. Check the LICENSE file for more details.---
