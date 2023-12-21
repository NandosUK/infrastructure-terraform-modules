locals {
  image = "thorn-technologies-public/sftpgw-3-4-4-1694633054"
  tags  = ["sftp-instance"]
  # https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
  gcp_healthcheck_ip_1 = "130.211.0.0/22"
  gcp_healthcheck_ip_2 = "35.191.0.0/16"
  # https://cloud.google.com/iap/docs/using-tcp-forwarding
  gcp_iap_ip = "35.235.240.0/20"
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

resource "google_compute_instance" "default" {
  project      = var.project
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = local.tags
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

module "load-balancer-sftp" {
  source                  = "../load-balancer"
  project                 = var.project
  zone                    = var.zone
  name                    = "${var.name}-sftp"
  port                    = 22
  google_compute_instance = google_compute_instance.default.self_link
  ip_address              = google_compute_global_address.default.address
}

# openssh access to the VM
# but you probably don't need ssh access to the vm
# module "load-balancer-ssh" {
#   source                  = "../load-balancer"
#   project                 = var.project
#   zone                    = var.zone
#   name                    = "${var.name}-ssh"
#   port                    = 2222
#   google_compute_instance = google_compute_instance.default.self_link
#   ip_address              = google_compute_global_address.default.address
# }

resource "google_compute_instance_group" "http" {
  name        = "http-ig"
  project     = var.project
  zone        = var.zone
  description = "Instance group for port 80/443"
  instances   = [google_compute_instance.default.self_link]

  named_port {
    name = "tcp-port-80"
    port = 80
  }

  named_port {
    name = "tcp-port-443"
    port = 443
  }
}

# HTTP/HTTPS load balancer w/ SSL
module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  project = var.project
  name    = "${var.name}-lb"
  version = "~> 9.0"

  # SSL and domain configuration
  managed_ssl_certificate_domains = [var.environment == "prod" ? var.domain : "${var.environment}.${var.domain}"]

  ssl                       = true
  https_redirect            = true # Enable HTTPS redirect
  random_certificate_suffix = true

  # Use the same IP as 22/2222 ports
  create_address = false
  address        = google_compute_global_address.default.address

  backends = {
    default = {
      groups = [
        {
          group = google_compute_instance_group.http.self_link
        }
      ]

      description             = "Backend for SFTP Server"
      enable_cdn              = false
      custom_request_headers  = ["X-Client-Geo-Location: {client_region_subdivision}, {client_city}"]
      custom_response_headers = ["X-Cache-Hit: {cdn_cache_status}"]

      log_config = {
        enable = false
      }
      iap_config = {
        enable = false
      }
    }
  }
}

resource "google_compute_firewall" "default" {
  name        = "${var.name}-fw"
  project     = var.project
  network     = google_compute_network.vpc_network.name
  target_tags = local.tags
  direction   = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22"]
  }
  source_ranges = concat(
    var.source_ranges,
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
resource "google_compute_router" "default" {
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
  router                             = google_compute_router.default.name
  name                               = "${var.name}-nat"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
