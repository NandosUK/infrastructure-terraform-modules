variable "name" {
  type        = string
  description = "Name of the SFTP server"
}

variable "google_storage_bucket" {
  type        = string
  description = "Name of your Google Storage bucket"
}

variable "project" {
  type        = string
  description = "Name of your Google Cloud project"
}

variable "environment" {
  type        = string
  description = "The environment you are running in (preview|preprod|prod)"
}


variable "region" {
  type        = string
  description = "Name of your Google Cloud region"
  default     = "europe-west2"
}

variable "zone" {
  type        = string
  description = "Name of your region zone"
  default     = "europe-west2-b"
}

variable "machine_type" {
  type        = string
  description = "Machine type of your VM"
  default     = "e2-small"
}

variable "ssh-keys" {
  type        = string
  description = "Key used to SSH into your VM. The format is ubuntu:ssh-rsa AAAAB3NzaC1, where you specify the username followed by the public key. If there are multiple SSH keys, each key is separated by a newline character (\\n)."
  default     = null
}

variable "source_ranges" {
  type        = list(string)
  description = "Source IP range"
  default     = []
}

variable "domain" {
  type        = string
  description = "Domain name to map to the server"
}
