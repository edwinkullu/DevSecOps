variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "node_locations" {
  description = "List of zones in which the cluster's nodes should be located to make it multi-zonal"
  type        = list(string)
  default     = []
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

variable "infra_service_account" {
  description = "The service account to impersonate for production infrastructure"
  type        = string
}

# -----------------------------------------------------------------------------
# GKE Specific Variables
# -----------------------------------------------------------------------------

variable "master_ipv4_cidr_block" {
  type    = string
  default = "10.100.0.0/28"
}

variable "cluster_name" {
  type    = string
  default = "postpilot-prod"
}

variable "dns_prefix" {
  type    = string
  default = "postpilotproddns"
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

variable "node_version" {
  type    = string
  default = "1.34.6-gke.1307000"
}

variable "gateway_api_channel" {
  description = "Channel for the Gateway API (standard or enterprise)"
  type        = string
  default     = "CHANNEL_STANDARD"
}

variable "gke_deletion_protection" {
  description = "Temporary GKE deletion protection toggle for controlled teardown"
  type        = bool
  default     = true
}
