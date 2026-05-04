output "load_balancer_ip" {
  value       = module.lb.lb_ip
  description = "External IP address of the HTTPS load balancer shell"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the foundational VPC network"
}
