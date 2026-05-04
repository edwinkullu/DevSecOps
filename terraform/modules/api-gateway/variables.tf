variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region for the API Gateway"
}

variable "api_id" {
  type        = string
  description = "ID of the API"
  default     = "main-api"
}

variable "name_prefix" {
  type        = string
  description = "Prefix for resources"
}
