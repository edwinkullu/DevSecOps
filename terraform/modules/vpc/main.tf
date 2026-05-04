resource "google_compute_network" "vpc" {
  name                    = "${var.name}-${var.environment}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name}-${var.environment}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id

  lifecycle {
    prevent_destroy = true
  }

  # ENFORCE: Private Google Access for secure API communication (Gemini, Vertex AI, etc.)
  private_ip_google_access = true

  # REQUIRED for GKE VPC-native clusters
  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = var.services_cidr
  }
}

# Firewall: allow Google LB health-checks and backend traffic
resource "google_compute_firewall" "allow_backend" {
  name    = "${var.name}-${var.environment}-allow-backend"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  target_tags = ["${var.name}-${var.environment}"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name}-${var.environment}-allow-ssh"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.name}-${var.environment}"]
}

# --- PRIVATE EGRESS: Cloud NAT ---
resource "google_compute_router" "router" {
  name    = "${var.name}-${var.environment}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.name}-${var.environment}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
