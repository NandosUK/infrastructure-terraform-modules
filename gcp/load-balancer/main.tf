variable "project" {}
variable "name" {}
variable "zone" {}
variable "port" {}
variable "google_compute_instance" {}
variable "ip_address" {}

locals {
  port_name = "tcp-port-${var.port}"
}

resource "google_compute_instance_group" "default" {
  name        = "${var.name}-ig"
  project     = var.project
  zone        = var.zone
  description = "Instance group for port ${var.port}"
  instances   = [var.google_compute_instance]
  named_port {
    name = local.port_name
    port = var.port
  }
}

resource "google_compute_health_check" "default" {
  name               = "${var.name}-health"
  timeout_sec        = 1
  check_interval_sec = 10
  project            = var.project
  tcp_health_check {
    port = 80
  }
  log_config {
    enable = true
  }
}

resource "google_compute_backend_service" "default" {
  name                  = "${var.name}-backend"
  project               = var.project
  protocol              = "TCP"
  port_name             = local.port_name
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
  port_range            = var.port
  target                = google_compute_target_tcp_proxy.default.id
  ip_address            = var.ip_address
}
