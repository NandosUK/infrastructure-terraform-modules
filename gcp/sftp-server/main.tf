locals {
  image                = "thorn-technologies-public/sftpgw-3-4-6-1702847260"
  tags                 = ["sftp-instance"]
  gcp_iap_ip           = "35.235.240.0/20"
  gcp_healthcheck_ip_1 = "130.211.0.0/22"
  gcp_healthcheck_ip_2 = "35.191.0.0/16"
}

resource "google_compute_network" "vpc_network" {
  name    = "${var.name}-net"
  project = var.project
}

resource "google_service_account" "default" {
  project      = var.project
  account_id   = "sftpuser"
  display_name = "Custom SA for SFTP VM Instance"
}

resource "google_project_iam_member" "sftpuser" {
  for_each = toset(["roles/compute.admin", "roles/storage.admin"])
  project  = var.project
  member   = google_service_account.default.member
  role     = each.key
}


resource "google_compute_instance" "sftp" {
  project      = var.project
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = ["http-server", "https-server", "lb-health-check", "sftp-instance"]
  boot_disk {
    initialize_params {
      image = local.image
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
  service_account {
    email  = google_service_account.default.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_global_address" "default" {
  name    = "${var.name}-ip"
  project = var.project
}

resource "google_compute_instance_group" "sftp_group" {
  name        = "sftp"
  project     = var.project
  zone        = var.zone
  description = "Instance group for port 22/443"
  instances   = [google_compute_instance.sftp.self_link]

  named_port {
    name = "sftp"
    port = 22
  }
  named_port {
    name = "https"
    port = 443
  }
}

resource "google_compute_health_check" "default" {
  name                = "${var.name}-health"
  timeout_sec         = 1
  check_interval_sec  = 120
  healthy_threshold   = 1
  unhealthy_threshold = 2
  project             = var.project
  tcp_health_check {
    port = 22
  }
  log_config {
    enable = true
  }
}

resource "google_compute_backend_service" "https" {
  name                  = "${var.name}-backend-https"
  project               = var.project
  protocol              = "TCP"
  port_name             = "https"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 10
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = google_compute_instance_group.sftp_group.self_link
    balancing_mode  = "CONNECTION"
    max_connections = 10
  }
  security_policy = google_compute_security_policy.sftp.name
}

resource "google_compute_backend_service" "sftp" {
  name                  = "${var.name}-backend-sftp"
  project               = var.project
  protocol              = "TCP"
  port_name             = "sftp"
  load_balancing_scheme = "EXTERNAL"
  timeout_sec           = 120
  health_checks         = [google_compute_health_check.default.id]
  backend {
    group           = google_compute_instance_group.sftp_group.self_link
    balancing_mode  = "CONNECTION"
    max_connections = 10
  }
  security_policy = google_compute_security_policy.sftp.name
}


resource "google_compute_target_tcp_proxy" "https" {
  name            = "${var.name}-proxy"
  project         = var.project
  backend_service = google_compute_backend_service.https.id
}

resource "google_compute_target_tcp_proxy" "sftp" {
  name            = "${var.name}-sftp-proxy"
  project         = var.project
  backend_service = google_compute_backend_service.sftp.id
}

resource "google_compute_global_forwarding_rule" "sftp-forward" {
  name                  = "${var.name}-sftp-fwd"
  project               = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = 22
  target                = google_compute_target_tcp_proxy.sftp.id
  ip_address            = google_compute_global_address.default.address
}

resource "google_compute_global_forwarding_rule" "https-forward" {
  name                  = "${var.name}-https-fwd"
  project               = var.project
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = 443
  target                = google_compute_target_tcp_proxy.https.id
  ip_address            = google_compute_global_address.default.address
}


resource "google_compute_firewall" "ingress" {
  name        = "${var.name}-fw"
  project     = var.project
  network     = google_compute_network.vpc_network.name
  target_tags = local.tags
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["443", "22"]
  }
  source_ranges = concat(
    [
      local.gcp_healthcheck_ip_1,
      local.gcp_healthcheck_ip_2,
      local.gcp_iap_ip,
      google_compute_global_address.default.address,
    ]
  )

}

resource "google_compute_firewall" "egress" {
  name        = "${var.name}-egress-fw"
  project     = var.project
  network     = google_compute_network.vpc_network.name
  direction   = "EGRESS"
  priority    = 1000
  target_tags = local.tags
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}

# router/NAT to allow egress traffic from sftp server without external IP
resource "google_compute_router" "sftp" {
  project = var.project
  name    = "${var.name}-router"
  network = google_compute_network.vpc_network.name
  region  = var.region
}

module "cloud-nat" {
  source                             = "terraform-google-modules/cloud-nat/google"
  version                            = "~> 5.0"
  project_id                         = var.project
  region                             = var.region
  router                             = google_compute_router.sftp.name
  name                               = "${var.name}-nat"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_security_policy" "sftp" {
  name = "unit4"

  rule {
    action   = "allow"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = var.whitelisted_ips
      }
    }
    description = "Allow Unit 4 IP addresses"
  }

  rule {
    action   = "deny(403)"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default deny access to all IPs"
  }
}