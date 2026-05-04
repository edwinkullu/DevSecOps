variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "me-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "me-central1-a"
}

variable "name" {
  description = "The prefix to use for all resource names"
  type        = string
  default     = "postpilot"
}

variable "environment" {
  description = "The environment name (e.g., uat, prod)"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR for the primary subnet"
  type        = string
}

variable "pods_cidr" {
  description = "CIDR for GKE pods"
  type        = string
}

variable "services_cidr" {
  description = "CIDR for GKE services"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the Load Balancer"
  type        = string
}

variable "cicd_deployer_name" {
  description = "Name of the CICD deployer service account"
  type        = string
}

variable "bucket" {
  description = "The GCS bucket for terraform state"
  type        = string
}

# -----------------------------------------------------------------------------
# GKE Specific Variables
# -----------------------------------------------------------------------------

variable "master_ipv4_cidr_block" {
  type    = string
  default = "10.102.0.0/28"
}

variable "cluster_name" {
  type    = string
  default = "postpilot-uat"
}

variable "dns_prefix" {
  type    = string
  default = "postpilotuatdns"
}

variable "initial_node_count" {
  type    = number
  default = 1
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 3
}

variable "machine_type" {
  type    = string
  default = "n2-standard-8"
}

variable "infra_service_account" {
  description = "The service account to impersonate for infrastructure provisioning"
  type        = string
}

variable "gateway_api_channel" {
  type    = string
  default = "CHANNEL_STANDARD"
}
