terraform {
  required_version = ">= 1.3.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  impersonate_service_account = var.infra_service_account
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  impersonate_service_account = var.infra_service_account
}

# --- VPC MODULE ---
module "vpc" {
  source = "../../modules/vpc"

  project_id    = var.project_id
  region        = var.region
  environment   = var.environment
  name          = var.name
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}

# --- LB MODULE ---
module "lb" {
  source = "../../modules/lb"

  project_id  = var.project_id
  region      = var.region
  environment = var.environment
  name        = var.name
  domain_name = var.domain_name
}

# --- SECURITY MODULE (KMS, Workload Identity) ---
module "security" {
  source = "../../modules/security"

  project_id         = var.project_id
  region             = var.region
  name               = var.name
  environment        = var.environment
  cicd_deployer_name = var.cicd_deployer_name
}

# --- GKE CLUSTER MODULE ---
module "gke_cluster" {
  source = "../../modules/gke-cluster"

  providers = {
    google      = google
    google-beta = google-beta
  }

  project_id = var.project_id
  zone       = var.zone
  name       = var.name
  network    = module.vpc.vpc_id
  subnetwork = module.vpc.subnet_id

  node_service_account = module.security.gke_sa_email

  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  initial_node_count     = var.initial_node_count
  min_node_count         = var.min_node_count
  max_node_count         = var.max_node_count
  machine_type           = var.machine_type
  cluster_name           = var.cluster_name
  dns_prefix             = var.dns_prefix
  gateway_api_channel    = var.gateway_api_channel
}

# --- API GATEWAY MODULE ---
import {
  to = module.api_gateway.google_api_gateway_api.api
  id = "projects/glassy-storm-491011-q6/locations/global/apis/postpilot-uat-main-api"
}

import {
  to = module.api_gateway.google_api_gateway_api_config.api_config
  id = "projects/glassy-storm-491011-q6/locations/global/apis/postpilot-uat-main-api/configs/postpilot-uat-main-api-config"
}

module "api_gateway" {
  source = "../../modules/api-gateway"

  project_id  = var.project_id
  region      = "europe-west1" # OVERRIDE: me-central1 does not support API Gateway
  name_prefix = "${var.name}-${var.environment}"
}
