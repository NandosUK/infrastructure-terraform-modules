# Terraform Google Pub/Sub Subscription Module README

## Overview

This Terraform module provides a robust and flexible configuration for creating Google Pub/Sub subscriptions. It is designed to streamline the setup of subscriptions for various environments such as development, preview, pre-production, and production. This module facilitates the creation of subscriptions that enable data ingestor services to receive and process messages efficiently. Deploy your Pub/Sub subscriptions to ensure your services are always in sync with the messages they need to process.

## Branching Strategy

The branching strategy for this module follows a standard approach to maintain separate development, testing, and production environments. Each branch corresponds to a specific stage in the development lifecycle, ensuring changes are systematically promoted through each stage before reaching production.

## Features

### Google Pub/Sub Subscription

- **Subscription Configuration** : Easy configuration of subscription names, topics, and acknowledgment deadlines.
- **Environment Specific Configurations** : Support for environment-specific settings such as project IDs.
- **Labels and Attributes** : Custom labels and attributes for easy management and filtering of subscriptions.
- **Push Configuration** : Configuration for push subscriptions, including endpoint and authentication settings.

### Security and Compliance

- **IAM Policies** : Support for assigning IAM policies to subscriptions for secure access control.
- **Encryption** : Options for encrypting messages at rest.

### Scalability and Reliability

- **Retry Policies** : Configuration for message delivery retry policies to ensure reliability.
- **High Availability** : Supports high availability settings for critical applications.

## New Variables

- `var.name`: Name of the subscription, reflecting the associated service.
- `var.topic_name`: The topic to which the subscription will subscribe.
- `var.environment`: Deployment environment (e.g., dev, preview, preprod, prod).
- `var.service_account_email`: The service account email used for authenticating push endpoint invocations.
- `var.push_endpoint`: The endpoint to which messages will be pushed.
- `var.audience`: The audience for the push endpoint authentication.

### Push Configuration Variables

- `var.push_endpoint`: URL of the service endpoint to receive messages.
- `var.attributes`: Key-value pairs for message metadata.
- `var.oidc_token`: OIDC token configuration for secure push delivery.

## Usage

This module simplifies the process of creating and managing Google Pub/Sub subscriptions across different environments. Use it to create subscriptions that match your operational and development needs, ensuring your data ingestor services are always updated with the latest information.

Example usage:

```hcl
module "pubsub_subscription" {
  source = "./path/to/pubsub/subscription/module"

  name                  = "example-subscription"
  topic_name            = "example-topic"
  environment           = "dev"
  service_account_email = "example@project.iam.gserviceaccount.com"
  push_endpoint         = "https://example-service.endpoint.com/receive"
  audience              = "https://example-service.endpoint.com"
}
```
