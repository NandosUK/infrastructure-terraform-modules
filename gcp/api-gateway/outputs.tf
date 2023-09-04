output "api_gateway_url" {
  value = google_api_gateway_gateway.nandos_api_gateway.default_hostname
}
