variable "project_id" {
  type        = string
  description = "GCP project ID"
}


variable "region" {
  type        = string
  description = "GCP region (KMS key rings are regional)"
}

variable "name" {
  type        = string
  description = "Base name prefix for all resources"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
}

variable "cicd_deployer_name" {
  description = "The name of the CICD deployer service account"
  type        = string
}
