terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

# Fetch project metadata — use .number to avoid hardcoding it as a variable
data "google_project" "current" {
  project_id = var.project_id
}

# --- WORKLOAD IDENTITY: GCP Service Account (GSA) for Applications ---
resource "google_service_account" "gke_sa" {
  account_id   = "${lower(var.name)}-${var.environment}-gke-sa"
  display_name = "GKE Service Account for ${var.name} (${var.environment}) - App Runtime"
}

# Grant Secret Manager AND Node Infrastructure access to the GKE service account
resource "google_project_iam_member" "gke_sa_roles" {
  for_each = toset([
    "roles/container.defaultNodeServiceAccount",
    "roles/secretmanager.secretAccessor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/artifactregistry.reader"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_sa.email}"
}

# --- CI/CD DEPLOYER: GCP Service Account for Cloud Build ---
resource "google_service_account" "cicd_deployer" {
  account_id   = var.cicd_deployer_name
  display_name = "CI/CD Deployer Service Account for ${var.name} (${var.environment})"
}

# IAM: Bind GSA to the shared Kubernetes Service Account (KSA) in the app namespace
resource "google_service_account_iam_member" "workload_identity_user" {
  service_account_id = google_service_account.gke_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[postpilot/postpilot-app-sa]"
}

# --- CI/CD PERMISSIONS ---
resource "google_project_iam_member" "deployer_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/storage.admin",
    "roles/compute.admin",
    "roles/container.admin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.secretAccessor",
    "roles/artifactregistry.writer"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.cicd_deployer.email}"
}
