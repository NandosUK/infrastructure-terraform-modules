output "public_ipv4_address" {
  value = google_compute_global_address.default.address
}
