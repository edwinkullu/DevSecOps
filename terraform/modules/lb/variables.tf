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

variable "domain_name" {
  description = "The root domain name for the Load Balancer (e.g., postpilot.ai)"
  type        = string
}

variable "name" {
  type        = string
  default     = "postpilot"
  description = "Base name prefix for all resources"
}
