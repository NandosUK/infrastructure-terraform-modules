output "public_ipv4_address" {
  value = module.lb-http.external_ip
}
output "public_ipv6_address" {
  value = module.lb-http.external_ipv6_address
}
