output "vpc_id" {
  value       = google_compute_network.vpc.id
  description = "Self-link / ID of the VPC network"
}

output "subnet_id" {
  value       = google_compute_subnetwork.subnet.id
  description = "Self-link / ID of the primary subnet"
}

output "vpc_name" {
  value       = google_compute_network.vpc.name
  description = "Name of the VPC network"
}

output "subnet_name" {
  value       = google_compute_subnetwork.subnet.name
  description = "Name of the primary subnet"
}
