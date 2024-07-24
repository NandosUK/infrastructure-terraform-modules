variable "name" {
  type        = string
  description = "Name of the SFTP server"
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
  default     = "e2-medium"
}

variable "ssh-keys" {
  type        = string
  description = "Key used to SSH into your VM. The format is ubuntu:ssh-rsa AAAAB3NzaC1, where you specify the username followed by the public key. If there are multiple SSH keys, each key is separated by a newline character (\\n)."
  default     = null
}

variable "enable_whitelist" {
  type = bool
  description = "enable or disable the whitelist"
  default = false

}

variable "whitelisted_ips" {
  type = list(string)
  description = "list of ip addresses to whitelist"
  default = ["*"]
}

