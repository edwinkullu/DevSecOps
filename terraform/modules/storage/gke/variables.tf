variable "environment" {
  type        = string
  description = "Environment label (dev, staging, prod)"
}

variable "itemCount" {
  type        = number
  description = "Number of disks to create"
}

variable "disk_prefix" {
  type        = string
  description = "Prefix for disk names"
}

variable "disk_size_gb" {
  type        = number
  description = "Size of each disk in GB"
}

variable "disk_type" {
  type        = string
  description = "Disk type (e.g. pd-standard, pd-ssd)"
  default     = "pd-ssd"
}

variable "zone" {
  type        = string
  description = "GCP zone for the persistent disk (disks are zone-scoped, not region-scoped)"
}