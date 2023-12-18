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

resource "google_compute_global_address" "default" {
  name    = "tcp-proxy-xlb-ip"
  project = var.project
}

resource "google_compute_target_tcp_proxy" "default" {
  name            = "${var.name}-proxy"
  project         = var.project
  backend_service = google_compute_backend_service.default.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.name}-fwd"
  project               = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "22"
  target                = google_compute_target_tcp_proxy.default.id
  ip_address            = google_compute_global_address.default.id
}

resource "google_compute_backend_service" "default" {
  name                  = "tcp-proxy-xlb-backend-service"
  project               = var.project
  protocol              = "TCP"
  port_name             = "tcp-port-22"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = google_compute_instance_group.default.self_link
    balancing_mode  = "UTILIZATION"
    max_utilization = 1.0
    capacity_scaler = 1.0
  }
}

resource "google_compute_health_check" "default" {
  name               = "${var.name}-health"
  timeout_sec        = 1
  check_interval_sec = 10
  project            = var.project
  tcp_health_check {
    port = "80"
  }
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

resource "google_compute_instance_group" "default" {
  name        = "${var.name}-ig"
  project     = var.project
  zone        = var.zone
  description = "Instance group for all ports"
  instances   = [google_compute_instance.default.self_link]
  named_port {
    name = "tcp-port-22"
    port = 22
  }
  named_port {
    name = "tcp-port-80"
    port = 80
  }
  named_port {
    name = "tcp-port-443"
    port = 443
  }
  named_port {
    name = "tcp-port-2222"
    port = 2222
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
  source_ranges = [google_compute_global_address.default.address]
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
  source_ranges = [google_compute_global_address.default.address]
}
