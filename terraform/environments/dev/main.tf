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
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# --- VPC MODULE ---
module "vpc" {
  source = "../../modules/vpc"

  project_id    = var.project_id
  region        = var.region
  environment   = "dev"
  name          = var.name
  subnet_cidr   = "10.0.0.0/24"
  pods_cidr     = "10.48.0.0/14"
  services_cidr = "10.52.0.0/20"
}

# --- LB MODULE ---
module "lb" {
  source = "../../modules/lb"

  project_id  = var.project_id
  region      = var.region
  environment = "dev"
  name        = var.name
}

# --- GKE CLUSTER MODULE ---
module "gke_cluster" {
  source = "../../modules/gke-cluster"

  project_id = var.project_id
  zone       = var.zone
  name       = var.name
  network    = module.vpc.vpc_id
  subnetwork = module.vpc.subnet_id

  master_ipv4_cidr_block = var.master_ipv4_cidr_block
  cluster_name           = var.cluster_name
  initial_node_count     = var.initial_node_count
  min_node_count         = var.min_node_count
  max_node_count         = var.max_node_count
  machine_type           = var.machine_type
}

# --- SECURITY MODULE (KMS, Workload Identity) ---
module "security" {
  source = "../../modules/security"

  project_id  = var.project_id
  region      = var.region
  name        = var.name
  environment = "dev"
}

# --- API GATEWAY MODULE ---
module "api_gateway" {
  source = "../../modules/api-gateway"

  project_id  = var.project_id
  region      = var.region
  name_prefix = "${var.name}-dev"
}
