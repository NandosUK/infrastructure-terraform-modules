# Main Trigger Name
variable "name" {
  type        = string
  description = "The name of the Cloud Build trigger."
}

# Trigger Description
variable "description" {
  type        = string
  description = "The description of the Cloud Build trigger."
}

variable "location" {
  type        = string
  default     = null
  description = "The location of the Cloud Build trigger. If not specify, the default location will be global."
}

# Filename of the build configuration
variable "filename" {
  type        = string
  default     = "cloudbuild.yaml"
  description = "The name of the Cloud Build configuration file."
}

# Substitution Variables
variable "substitutions" {
  type = map(string)
  default = {
    _LOCATION = "europe-west2"
  }
  description = "Map of substitution variables to be used in the build process."
}


# Github Repository Owner
variable "repository_owner" {
  type        = string
  default     = "NandosUK"
  description = "The owner of the GitHub repository."
}

# Github Repository Name
variable "repository_name" {
  type = string

  description = "The name of the GitHub repository where the service is located"
}

# Included Files
variable "include" {
  type        = list(string)
  default     = ["**"]
  description = "List of file paths that should be included in the build."
}

# Excluded Files
variable "exclude" {
  type        = list(string)
  default     = []
  description = "List of file paths that should be excluded from the build."
}

variable "environment" {
  type        = string
  description = "Environment that can be preview, preprod, dev or prod"

  validation {
    condition     = contains(["preview", "preprod", "prod", "dev"], var.environment)
    error_message = "The environment must be one of: preview, preprod, dev or prod."
  }
}


variable "branching_strategy" {
  description = "Branching strategy for different environments"
  type        = map(any)
  default = {
    dev = {
      validate = {
        branch       = "^NOT_USED_PREVIEW$"
        invert_regex = false
      }
      provision = {
        branch       = ".*"
        invert_regex = false
      }
    },
    preview = {
      validate = {
        branch       = "^NOT_USED_PREVIEW$"
        invert_regex = false
      }
      provision = {
        branch       = ".*"
        invert_regex = false
      }
    },
    preprod = {
      validate = {
        branch       = "^main$|^preprod$|^release/(.*)$"
        invert_regex = true
      }
      provision = {
        branch       = "^main$|^preprod$|^release/(.*)$"
        invert_regex = false
      }
    },
    prod = {
      validate = {
        branch       = "^main$"
        invert_regex = true
      }
      provision = {
        branch       = "^main$"
        invert_regex = false
      }
    }
  }
}


# Tags
variable "tags" {
  type        = list(string)
  default     = []
  description = "List of tags to add to the Cloud Build trigger."
}

# Disabled
variable "disabled" {
  type        = bool
  default     = false
  description = "Flag to specify if the trigger is disabled."
}
