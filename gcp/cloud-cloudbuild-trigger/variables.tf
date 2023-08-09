variable "name" {}

variable "description" {}

variable "filename" {
  default = "cloudbuild.yaml"
}

variable "substitutions" {
  type = map(string)
  default = {
    _LOCATION = "europe-west2"
  }
}
variable "branch" {
  default = "DEFAULT"
}

variable "invert_regex" {
  default = false
}

variable "repository_owner" {
  default = "NandosUK"
}

variable "repository_name" {
  default = ""
}

variable "include" {
  type    = list(string)
  default = ["**"]
}
variable "exclude" {
  type    = list(string)
  default = []
}

variable "project" {
  default = ""
}

variable "create_for_dev" {
  type    = bool
  default = true
}

variable "tags" {
  default = []
}

variable "disabled" {
  default = false
}
