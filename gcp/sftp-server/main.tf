resource "google_storage_bucket" "bucket" {
  name     = "${var.google_storage_bucket}-${var.project}"
  location = var.region
  project  = var.project
}

resource "google_compute_network" "vpc_network" {
  name    = "${var.name}-net"
  project = var.project
}

resource "google_compute_address" "static" {
  name    = "${var.name}-ip"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "default" {
  project      = var.project
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = ["terraform-instance"]
  boot_disk {
    initialize_params {
      image = "thorn-technologies-public/sftpgw-3-4-4-1694633054"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  metadata = {
    ssh-keys = var.ssh-keys
  }
  shielded_instance_config {
    enable_secure_boot = true
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
  target_tags   = ["terraform-instance"]
  source_ranges = var.source_ranges
}

resource "google_compute_firewall" "sftp-port-22" {
  name    = "${var.name}-sftp-fw"
  project = var.project
  network = google_compute_network.vpc_network.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags   = ["terraform-instance"]
  source_ranges = ["0.0.0.0/0"]
}

output "public_ip_address" {
  value = google_compute_address.static.address
}
