variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "me-central1"
}

variable "name" {
  description = "The prefix to use for all resource names (replaces POSTPILOTAI)"
  type        = string
  default     = "postpilot"
}
