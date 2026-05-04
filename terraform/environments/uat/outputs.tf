output "load_balancer_ip" {
  value       = module.lb.lb_ip
  description = "External IP address of the HTTPS load balancer for stage"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the foundational VPC network for stage"
}

output "cluster_endpoint" {
  value       = module.gke_cluster.cluster_endpoint
  description = "GKE Cluster endpoint"
}

/*
output "lb_ssl_dns_auth_name" {
  value       = module.lb.ssl_dns_auth_name
  description = "The CNAME name to add to DNS for SSL validation (Stage)"
}

output "lb_ssl_dns_auth_value" {
  value       = module.lb.ssl_dns_auth_value
  description = "The CNAME value to add to DNS for SSL validation (Stage)"
}
*/

