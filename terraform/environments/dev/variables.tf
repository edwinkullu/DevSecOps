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

variable "bucket" {
  description = "The GCS bucket for terraform state"
  type        = string
}

# GKE Specific Variables
variable "master_ipv4_cidr_block" {
  type    = string
  default = "10.101.0.0/28"
}

variable "cluster_name" {
  type    = string
  default = "postpilot-dev"
}

variable "dns_prefix" {
  type    = string
  default = "postpilotdevdns"
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
  default = "e2-medium"
}
