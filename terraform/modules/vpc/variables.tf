variable "project_id" {
  type        = string
  description = "GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "name" {
  type        = string
  default     = "postpilot"
  description = "Base name prefix for all resources"
}

variable "subnet_cidr" {
  type        = string
  description = "Primary CIDR for the subnet"
}

variable "pods_cidr" {
  type        = string
  description = "Secondary CIDR range for GKE pods"
}

variable "services_cidr" {
  type        = string
  description = "Secondary CIDR range for GKE services"
}
