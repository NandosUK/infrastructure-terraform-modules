# API Gateway Terraform Module for Google Cloud Platform

This Terraform module allows you to set up an API Gateway on Google Cloud Platform. The module creates the necessary infrastructure, including the service account with permissions and the API Gateway itself.

## Requirements

1. Google Cloud Platform (GCP) account
2. Terraform installed
3. Google Cloud SDK (Optional)

You will also need to ensure the following APIs are enabled in your GCP project:
- apigateway.googleapis.com
- servicecontrol.googleapis.com
- servicemanagement.googleapis.com
- serviceusage.googleapis.com
- apikeys.googleapis.com

and grant these roles for your cloud build service account:
- roles/apigateway.admin
- roles/serviceusage.serviceUsageAdmin
- roles/serviceusage.apiKeysAdmin

This can be done in the [infrastructure](https://github.com/NandosUK/infrastructure/blob/master/gcp/organization/environment/inputs-for-unrestricted.auto.tfvars) repository, where your project is defined.

## Resources Created

- Google Cloud Service Account for the API Gateway
- API Gateway API Resource
- API Gateway API Config
- API Gateway with regional deployment
- API Keys to authenticate calls and add resource quotas

## Usage

Refer to the example Terraform script in the example folder for a demonstration on how to use this updated module.

Example of use:

[test/gcp/api-gateway.tf](../../test/gcp/api-gateway.tf)

Make sure you have a Open API spec file that defines your API:

You can find one here:

[test/assets/api-gateway-example.yml](../../test/assets/api-gateway-example.yml)

Also we enable a [Backstage template](https://backstage.nandos.dev/create) to generate a custom one.
