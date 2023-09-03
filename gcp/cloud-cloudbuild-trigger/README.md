# Google Cloud Build Trigger Terraform Module

This module creates a Google Cloud Build Trigger, allowing you to automatically run builds on source code changes... The trigger can be configured to listen for changes on specific branches, include or exclude specific files, and apply custom substitutions during the build.

# Branching Strategy Details for Cloud Build Trigger

This document provides an in-depth explanation of the `branching_strategy` variable in our Terraform configuration for Google Cloud Build triggers.

## Environments and Stages

The strategy is defined for three different environments:

- Preview
- Preprod
- Prod

In each environment, there are two stages:

- `validate`: Checks to perform before the actual build
- `provision`: The build process itself

## Preview Environment

### Validate Stage

- **branch**: `^NOT_USED_PREVIEW$`
  - The preview environment doesn't use any branches for validation.
  
- **invert_regex**: `false`
  - Don't invert the regex, so the branch pattern is used as-is.

### Provision Stage

- **branch**: `.*`
  - Any branch can trigger provisioning.

- **invert_regex**: `false`
  - Don't invert the regex.

## Preprod Environment

### Validate Stage

- **branch**: `^main$|^preprod$|^release/(.*)$`
  - The `main`, `preprod`, and `release/*` branches can be used for validation.

- **invert_regex**: `true`
  - Invert the regex, so these branches will not trigger the validate step.

### Provision Stage

- **branch**: `^main$|^preprod$|^release/(.*)$`
  - The `main`, `preprod`, and `release/*` branches can trigger provisioning.

- **invert_regex**: `false`
  - Don't invert the regex.

## Prod Environment

### Validate Stage

- **branch**: `^main$`
  - Only the `main` branch is used for validation.

- **invert_regex**: `true`
  - Invert the regex, so this branch will not trigger the validate step.

### Provision Stage

- **branch**: `^main$`
  - Only the `main` branch can trigger provisioning.

- **invert_regex**: `false`
  - Don't invert the regex.
