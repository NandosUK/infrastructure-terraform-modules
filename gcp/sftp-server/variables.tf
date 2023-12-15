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
  description = "Key used to SSH into your VM"
  default     = null
}

variable "source_ranges" {
  type        = list(string)
  description = "Source IP range"
  default     = []
}
