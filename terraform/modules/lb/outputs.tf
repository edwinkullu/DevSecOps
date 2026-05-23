output "lb_ip" {
  value       = google_compute_global_address.ip.address
  description = "External IP of the HTTPS load balancer"
}

/*
output "url_map_id" {
  value       = google_compute_url_map.map.id
  description = "ID of the URL map (used by GKE Ingress to attach NEG backends)"
}
*/

output "ssl_dns_auth_name" {
  value       = google_certificate_manager_dns_authorization.wildcard_auth.dns_resource_record[0].name
  description = "The CNAME name to add to DNS for SSL validation"
}

output "ssl_dns_auth_value" {
  value       = google_certificate_manager_dns_authorization.wildcard_auth.dns_resource_record[0].data
  description = "The CNAME value to add to DNS for SSL validation"
}

