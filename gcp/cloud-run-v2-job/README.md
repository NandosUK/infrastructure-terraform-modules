# Overview

This updated Terraform module is designed for deploying jobs to Google Cloud Run, adapting the versatility and ease of deploying services to the specific needs of job execution in a serverless environment. It extends the capabilities of Google Cloud Run services to jobs, allowing for scheduled tasks, batch processing, and one-off executions with the same level of configurability and scalability. Deploy your Cloud Run jobs efficiently and manage them seamlessly within the Google Cloud ecosystem.

## Branching Strategy

[Details about the branching strategy](https://chat.openai.com/cloud-cloudbuild-trigger/README.md)

## Features

### Google Cloud Run Job

- **Job Name and Location** : Customizable name and deployment region for the job.
- **Service Account** : Specify a service account for executing the job with appropriate permissions.
- **Execution Environment** : Control over the job's execution environment, including CPU and memory resources.
- **Environment Variables and Secrets** : Support for dynamic environment variables and secrets to configure the job execution context.
- **Retry Policy** : Configuration options for job retries upon failure.
- **Scheduled Execution** : Ability to define schedules for job execution using Cloud Scheduler.
- **Artifact Repository** : Define the artifact repository for the job container image.
- **Alert Configuration** : Set up custom alerting for job execution status.

### Cloud Build Trigger for Jobs

- **Trigger Configuration** : Advanced configuration for Cloud Build triggers specific to job deployment, including environment variables and artifact repository settings.

## New Variables

- `var.project_id`: The ID of the project where the job will be deployed.
- `var.name`: Unique name for the Cloud Run job.
- `var.project_region`: Deployment region for the Cloud Run job.
- `var.cloud_run_service_account`: The service account to use for executing the Cloud Run job.
- `var.environment`: Specifies the job's environment (e.g., development, production).
- `var.artifact_repository`: The Docker artifact repository for the job container image.
- `var.repository_name`: Name of the repository where the job's source code is located.
- `var.env_vars`: Environment variables to set for the job's execution environment.
- `var.secrets`: List of secrets from Secret Manager to be made available to the job.
- `var.timeout`: Maximum allowed time duration the job may be active before being terminated.
- `var.cpu_limit`, `var.memory_limit`: Resource limits for the job's container.
- `var.max_retries`: Maximum number of retries for failed job executions.
- `var.alert_config`: Configuration settings for alerts based on job execution and status.

### Job Execution and Retry Policy Variables

- `var.schedule`: Cron schedule for job execution (if applicable).
- `var.attempt_deadline`: The deadline for each attempt of the job execution.
- `var.retry_policy`: Policy for retrying failed job executions.

See code for the complete list of available variables.

## Usage

For a practical demonstration of using this module to deploy Cloud Run jobs, refer to the example Terraform script in the example folder.

Example of use:

[test/gcp/cloud-run-job-v2.tf](https://chat.openai.com/test/gcp/cloud-run-job-v2.tf)
