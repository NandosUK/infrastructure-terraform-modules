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

## Inputs

name (String): The name of the trigger.

description (String): The description of the trigger.

filename (String): The path to the Cloud Build configuration file. Defaults to "cloudbuild.yaml".

substitutions (Map): Key-value pairs to define substitutions during the build. Defaults to {\_LOCATION = "europe-west2"}.

branch (String): The branch to trigger builds on. Defaults to "DEFAULT".

invert_regex (Boolean): Whether to invert the regex on the branch. Defaults to false.

repository_owner (String): Owner of the repository. Defaults to "NandosUK".

repository_name (String): Name of the repository. Defaults to an empty string.

include (List): Files to include in the build. Defaults to ["**"].

exclude (List): Files to exclude from the build. Defaults to [].

tags (List): Tags for the trigger. Defaults to [].

disabled (Boolean): Whether the trigger is disabled. Defaults to false.

create_for_dev (Boolean): Controls creation of triggers for the development environment. Defaults to true.

project (String): The project where the trigger will be created. Defaults to an empty string.
