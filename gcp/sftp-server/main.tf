locals {
  tags = ["terraform-instance"]
}

resource "google_storage_bucket" "bucket" {
  name     = "${var.google_storage_bucket}-${var.project}"
  location = var.region
  project  = var.project
}

resource "google_compute_network" "vpc_network" {
  name    = "${var.name}-net"
  project = var.project
}

resource "google_compute_instance" "default" {
  project      = var.project
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = local.tags
  boot_disk {
    initialize_params {
      image = "thorn-technologies-public/sftpgw-3-4-4-1694633054"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
  }
  metadata = {
    ssh-keys = var.ssh-keys
  }
  shielded_instance_config {
    enable_secure_boot = true
  }
}

resource "google_compute_instance_group" "http-instance-group" {
  name        = "${var.name}-http-ig"
  project     = var.project
  zone        = var.zone
  description = "Instance group for HTTP"
  named_port {
    name = "tcp-port-80"
    port = 80
  }
}

resource "google_compute_instance_group" "https-instance-group" {
  name        = "${var.name}-https-ig"
  project     = var.project
  zone        = var.zone
  description = "Instance group for HTTPS"
  named_port {
    name = "tcp-port-443"
    port = 443
  }
}

resource "google_compute_instance_group" "ssh-instance-group" {
  name        = "${var.name}-ssh-ig"
  project     = var.project
  zone        = var.zone
  description = "Instance group for SSH"
  named_port {
    name = "tcp-port-22"
    port = 22
  }
}

resource "google_compute_instance_group" "sftp-instance-group" {
  name        = "${var.name}-sftp-ig"
  project     = var.project
  zone        = var.zone
  description = "Instance group for SFTP"
  named_port {
    name = "tcp-port-2222"
    port = 2222
  }
}

module "lb-http" {
  source      = "GoogleCloudPlatform/lb-http/google"
  version     = "~> 9.0"
  project     = var.project
  name        = "${var.name}-lb"
  target_tags = local.tags
  backends = {
    http = {
      port        = 80
      protocol    = "HTTP"
      port_name   = "tcp-port-80"
      timeout_sec = 10
      enable_cdn  = false
      groups = [
        {
          group = google_compute_instance_group.http-instance-group.self_link
        },
      ]
      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
      health_check = {
        port     = 80
        protocol = "HTTP"
        path     = "/"
      }
    }
    https = {
      port        = 443
      protocol    = "HTTPS"
      port_name   = "tcp-port-443"
      timeout_sec = 10
      enable_cdn  = false
      groups = [
        {
          group = google_compute_instance_group.https-instance-group.self_link
        },
      ]
      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
      health_check = {
        port     = 443
        protocol = "HTTPS"
        path     = "/"
      }
    }
    ssh = {
      port        = 22
      protocol    = "TCP"
      port_name   = "tcp-port-22"
      timeout_sec = 10
      enable_cdn  = false
      groups = [
        {
          group = google_compute_instance_group.ssh-instance-group.self_link
        },
      ]
      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
      health_check = {
        port     = 22
        protocol = "TCP"
      }
    }
    sftp = {
      port        = 2222
      protocol    = "TCP"
      port_name   = "tcp-port-2222"
      timeout_sec = 10
      enable_cdn  = false
      groups = [
        {
          group = google_compute_instance_group.sftp-instance-group.self_link
        },
      ]
      iap_config = {
        enable = false
      }
      log_config = {
        enable = false
      }
      health_check = {
        port     = 2222
        protocol = "TCP"
      }
    }
  }
}

resource "google_compute_firewall" "default" {
  name    = "${var.name}-fw"
  project = var.project
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "2222"]
  }
  target_tags   = local.tags
  source_ranges = compact([module.lb-http.external_ip, module.lb-http.external_ipv6_address])
}

resource "google_compute_firewall" "sftp-port-22" {
  name    = "${var.name}-sftp-fw"
  project = var.project
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = local.tags
  source_ranges = compact([module.lb-http.external_ip, module.lb-http.external_ipv6_address])
}
