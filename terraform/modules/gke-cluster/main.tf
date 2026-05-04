terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0"
    }
  }
}

resource "google_container_cluster" "primary" {
  provider = google-beta
  name     = var.cluster_name != "" ? var.cluster_name : "${var.name}-gke-cluster"
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  node_locations           = length(var.node_locations) > 0 ? var.node_locations : null

  network    = var.network
  subnetwork = var.subnetwork

  networking_mode = "VPC_NATIVE"

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  # --- PRIVATE CLUSTER CONFIG ---
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # Set to true only if accessing via VPN/Interconnect
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Enable Dataplane V2 for high-performance networking and Kubernetes Network Policies support
  datapath_provider = "ADVANCED_DATAPATH"

  # --- WORKLOAD IDENTITY ---
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Add any required cluster-level features here
  addons_config {
    http_load_balancing {
      disabled = false
    }
    gcs_fuse_csi_driver_config {
      enabled = true
    }
  }

  gateway_api_config {
    channel = var.gateway_api_channel
  }

  # Secret Manager CSI Driver is a top-level block in newer provider versions
  secret_manager_config {
    enabled = true
  }

  release_channel {
    channel = "STABLE"
  }

  deletion_protection = var.deletion_protection

  # Secret Manager is used for DB URLs; GKE uses default Google-managed encryption for its etcd
  database_encryption {
    state = "DECRYPTED"
  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      node_config,
    ]
  }
}

resource "google_container_node_pool" "primary_nodes" {
  provider           = google-beta
  name               = "${var.name}-node-pool"
  location           = var.zone
  node_locations     = length(var.node_locations) > 0 ? var.node_locations : null
  version            = var.node_version != "" ? var.node_version : null
  cluster            = google_container_cluster.primary.name
  initial_node_count = var.initial_node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type

    # Standard tags for firewall consistency
    tags = [var.name, "gke-node"]

    service_account = var.node_service_account

    metadata = {
      disable-legacy-endpoints = "true"
    }

    # REQUIRED for Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
