output "load_balancer_ip" {
  value       = module.lb.lb_ip
  description = "External IP address of the HTTPS load balancer shell"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the foundational VPC network"
}

/*
output "lb_ssl_dns_auth_name" {
  value       = module.lb.ssl_dns_auth_name
  description = "The CNAME name to add to DNS for SSL validation (Production)"
}

output "lb_ssl_dns_auth_value" {
  value       = module.lb.ssl_dns_auth_value
  description = "The CNAME value to add to DNS for SSL validation (Production)"
}
*/


output "gke_sa_email" {
  value = module.security.gke_sa_email
}

output "project_id" {
  value = var.project_id
}
