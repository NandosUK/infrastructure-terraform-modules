# Overview

This Terraform module provides a comprehensive set of reusable configurations for deploying services to Google Cloud Run service / api. It extends the previous version by incorporating new variables like Cloud Armor for security, advanced probe settings, and more. Deploy your Cloud Run services easily and make them available on `https://MY_SERVICE.api.nandos.dev`.

## Branching Strategy

[Details about the branching strategy](https://chat.openai.com/cloud-cloudbuild-trigger/README.md)

## Features

### Google Cloud Run Service

- **Service Name and Location** : Customizable name and deployment region.
- **Service Account** : Optional service account that will be used as role/invoker.
- **Ingress Settings** : Control ingress traffic, including the option for public access.
- **Startup and Liveness Probes** : Advanced configuration for health checks.
- **Environment Variables and Secrets** : Support for dynamic environment variables and secrets.
- **SQL and Shared VPC Connection** : Optional SQL and shared VPC connections.
- **Artifact Repository** : Define the artifact repository for the service.
- **Cloud Armor** : Integrated Cloud Armor support for enhanced security.
- **Alert Configuration** : Set up custom alerting.

### Network Endpoint Group (NEG)

- **NEG Creation** : Creates a Network Endpoint Group for Load Balancer integration.

### Load Balancer with Serverless NEG

- **SSL and Domain** : Optional SSL and custom domain settings.

### EventArc Trigger

Key elements description:

- **matching_criteria** : matching criteria for the trigger, including attributes like "attribute," "value", and "operator"(optional) to filter specific events.
- **event_data_content_type** : Sets the event's content type.
- **api_path** : to specify the URL path that will be appended to the service's base URL

### Cloud Build Trigger

- **Advanced Trigger Config** : More granular control over Cloud Build triggers.

## New Variables

- `var.cloud_run_service_account`: The service account used as the Eventarc trigger invoker, and as the Cloud Run service identity when `use_custom_service_account` is `true`.
- `var.use_custom_service_account`: When `true`, the Cloud Run service runs as `cloud_run_service_account` instead of the default Compute Engine SA. Defaults to `false` to avoid changing existing deployments.
- `var.sharedVpcConnector`: Shared VPC connection string for internal network access.
- `var.environment`: The current environment.
- `var.artifact_repository`: The artifact repository for the service.
- `var.repository_name`: GitHub repository name where the service is located.
- `var.trigger_config`: Cloud Build Trigger configuration.
- `var.alert_config`: Custom alert configuration.
- `var.cloud_armor`: Cloud Armor configuration settings. `rules_file_path` (optional) points to a YAML file of IP-range rules. `waf_rules` (optional, default none) lists Google preconfigured WAF rule sets, e.g. `["sqli-v33-stable", "xss-v33-stable"]`, evaluated before the IP rules. `waf_preview` (default `true`) logs matches without blocking; set it to `false` to enforce. `waf_sensitivity` (default `1`) sets the sensitivity level.

### Startup and Liveness Probe Variables

- `var.startup_probe_initial_delay`
- `var.startup_probe_timeout`
- `var.startup_probe_period`
- `var.startup_probe_failure_threshold`
- `var.startup_probe_port`
- `var.liveness_probe_path`

See code for the complete list of available variables.

## Usage

Refer to the example Terraform script in the example folder for a demonstration on how to use this updated module.

Example of use:

[test/gcp/cloud-run-v2.tf](https://chat.openai.com/test/gcp/cloud-run-v2.tf)

## Contribution

Contributions are welcome! Please open an issue or submit a pull request.

## License

This module is released under the MIT License. Check the LICENSE file for more details.---
