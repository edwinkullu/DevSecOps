variable "project_id" {
  type = string
}

variable "zone" {
  type        = string
  description = "GCP zone for the GKE cluster (zone-scoped = faster upgrades)"
}

variable "node_locations" {
  type        = list(string)
  description = "List of zones in which the cluster's nodes should be located to make it multi-zonal"
  default     = []
}


variable "name" {
  type        = string
  description = "Base name prefix for GKE resources"
}

variable "cluster_name" {
  type        = string
  description = "Override the GKE cluster name (e.g. POSTPILOT-UAT, POSTPILOT-PROD). Defaults to <name>-gke-cluster."
  default     = ""
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix used in cluster resource naming (mirrors aks_dns_prefix)"
  default     = ""
}

variable "network" {
  type        = string
  description = "The VPC self-link / ID"
}

variable "subnetwork" {
  type        = string
  description = "The subnet self-link / ID"
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "IP range for the GKE control plane (must not overlap with node/pod/svc CIDRs)"
}

# ── Node pool sizing (mirrors AKS initial / min / max) ──────────────────────

variable "initial_node_count" {
  type        = number
  description = "Initial number of nodes per zone at cluster creation"
  default     = 1
}

variable "min_node_count" {
  type        = number
  description = "Minimum nodes for Cluster Autoscaler"
  default     = 1
}

variable "max_node_count" {
  type        = number
  description = "Maximum nodes for Cluster Autoscaler"
  default     = 3
}

variable "node_version" {
  type        = string
  description = "The Kubernetes version for the nodes"
  default     = ""
}

variable "machine_type" {
  type        = string
  description = "GCE machine type for node pool VMs"
}

variable "preemptible" {
  type    = bool
  default = false
}

variable "node_service_account" {
  type        = string
  description = "The service account email to be used by the node pool"
}

variable "gateway_api_channel" {
  type        = string
  description = "The Gateway API channel for the cluster (CHANNEL_DISABLED or CHANNEL_STANDARD)"
  default     = "CHANNEL_DISABLED"
}

variable "deletion_protection" {
  type        = bool
  description = "Whether the GKE cluster should be protected from deletion"
  default     = true
}

