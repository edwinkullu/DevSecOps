variable "db_instance_name" {
  type        = string
  description = "Name of the Cloud SQL instance"
}
variable "db_cpu" {
  type        = number
  description = "Number of CPUs for the Cloud SQL tier"
}
variable "db_memory_mb" {
  type        = number
  description = "Memory (MB) for the Cloud SQL tier"
}
variable "db_disk_size_gb" {
  type        = number
  description = "Disk size in GB for Cloud SQL"
}
variable "db_max_connections" {
  type        = number
  description = "max_connections flag value for Postgres"
}
variable "region" {
  type        = string
  description = "GCP region"
}
variable "vpc_id" {
  type        = string
  description = "VPC self-link for private IP config"
}
variable "db_name" {
  type        = string
  description = "Name of the Postgres database to create"
}
variable "db_username" {
  type        = string
  description = "Postgres admin username"
}
variable "db_password" {
  type        = string
  sensitive   = true
  description = "Postgres admin password"
}
variable "db_charset" {
  type    = string
  default = "UTF8"
}
variable "db_collation" {
  type    = string
  default = "en_US.UTF8"
}
