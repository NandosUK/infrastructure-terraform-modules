# Google Cloud Run Module

This Terraform module deploys a Google Cloud Run service, configures public access (if desired), creates a Network Endpoint Group (NEG), and sets up a Load Balancer with SSL and domain configuration. Additionally, it includes a Cloud Build trigger for continuous integration and deployment.

## Usage

See example on:

`test/gcp/cloud-run-v2.tf`