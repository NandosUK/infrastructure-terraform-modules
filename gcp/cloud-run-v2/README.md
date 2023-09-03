# Terraform Google Cloud Run Module README

## Overview

This Terraform module provides a set of reusable configurations for deploying services to Google Cloud Run, a fully managed serverless platform for running containerized applications. The module is designed for flexibility and ease-of-use, allowing users to deploy Cloud Run services with customized probes, environment variables, and even secrets from Google Cloud Secret Manager.

Once the service is created it will become available on `https://MY_SERVICE.api.nandos.services`

## Features

### Google Cloud Run Service

- **Service Name and Location** : Easily set the name and deployment region for your Cloud Run service.
- **Ingress Settings** : By default, allows ingress traffic from all sources.
- **Startup and Liveness Probes** : Configure startup and liveness probes to monitor the health of your service.
- **Environment Variables and Secrets** : Dynamically set environment variables and secrets.
- **Resource Limits** : Define CPU and memory limitations for your service.
- **Scalability** : Set the minimum and maximum number of instances for your service.
- **Volume Mounts** : Conditionally enable volume mounts, useful for SQL connections.

### Network Endpoint Group (NEG)

- Creates a Network Endpoint Group for the Cloud Run service for Load Balancer integration.

### Load Balancer with Serverless NEG

- Utilizes the Google Cloud Load Balancer module with support for serverless Network Endpoint Groups.
- Optional SSL and domain configurations.

### Cloud Build Trigger

- Creates a Cloud Build trigger for CI/CD, conditional based on the `var.create_trigger` flag.

## Variables

- `var.name`: Name of the Cloud Run service.
- `var.project_region`: Google Cloud region where the service is deployed.
- `var.env_vars`: Map of environment variables for the service.
- `var.secrets`: List of secret keys from Google Cloud Secret Manager.
- `var.cpu_limit`: CPU limit for the service.
- `var.memory_limit`: Memory limit for the service.
- `var.max_scale`: Maximum number of instances for the service.
- `var.min_scale`: Minimum number of instances for the service.
- `var.sql_connection`: SQL connection string, if needed.
- `var.allow_public_access`: Flag to control public access.
- `var.project_id`: Google Cloud project ID.

... and many more. See the code for all available variables.

## Usage

To use this module, include it in your Terraform script and fill in the required variables. Check out the example folder for a sample Terraform script that uses this module.

`test/gcp/cloud-run-v2.tf`

## Contribution

Contributions are welcome! Feel free to open an issue or submit a pull request.

## License

This module is released under the MIT License. See the LICENSE file for more details.
