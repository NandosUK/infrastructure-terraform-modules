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

# Git Branch
variable "branch" {
  type        = string
  default     = "DEFAULT"
  description = "The name of the git branch for which to trigger the build."
}

# Invert Regex
variable "invert_regex" {
  type        = bool
  default     = false
  description = "If true, regex matching is inverted."
}

# Github Repository Owner
variable "repository_owner" {
  type        = string
  default     = "NandosUK"
  description = "The owner of the GitHub repository."
}

# Github Repository Name
variable "repository_name" {
  type        = string
  default     = ""
  description = "The name of the GitHub repository."
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
