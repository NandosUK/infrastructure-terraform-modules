# Google Cloud Build Trigger Terraform Module

This module creates a Google Cloud Build Trigger, allowing you to automatically run builds on source code changes. The trigger can be configured to listen for changes on specific branches, include or exclude specific files, and apply custom substitutions during the build.

## Usage

```hcl
module "trigger_main" {
  source            = "github.com/NandosUK/infrastructure-terraform-modules//gcp/cloud-build-trigger-v1"
  name              = "my-trigger"
  description       = "A sample Google Cloud Build Trigger."
  repository_owner  = "NandosUK"
  repository_name   = "my-repo"
  branch            = "main"
  invert_regex      = false
  substitutions     = {
    _LOCATION = "europe-west2"
  }
  include           = ["**"]
  exclude           = []
  disabled          = false
  tags              = ["example-tag"]
}
```

## Inputs

| Name               | Description                                    | Type         | Default                          |
| ------------------ | ---------------------------------------------- | ------------ | -------------------------------- |
| `name`             | The name of the trigger                        | string       |                                  |
| `description`      | The description of the trigger                 | string       |                                  |
| `filename`         | Path to the Cloud Build configuration file     | string       | `"cloudbuild.yaml"`              |
| `substitutions`    | Key-value pairs for substitutions during build | map(string)  | `{ _LOCATION = "europe-west2" }` |
| `branch`           | Branch to trigger builds on                    | string       | `"DEFAULT"`                      |
| `invert_regex`     | Whether to invert the regex on the branch      | bool         | `false`                          |
| `repository_owner` | Owner of the repository                        | string       | `"NandosUK"`                     |
| `repository_name`  | Name of the repository                         | string       |                                  |
| `include`          | Files to include in the build                  | list(string) | `["**"]`                         |
| `exclude`          | Files to exclude from the build                | list(string) | `[]`                             |
| `tags`             | Tags for the trigger                           | list         | `[]`                             |
| `disabled`         | Whether the trigger is disabled                | bool         | `false`                          |
| `project`          | The project where the trigger will be created  | string       |                                  |
