# IAM configuration for GKE and Artifact Registry access

locals {
  compute_sa = "69548092470-compute@developer.gserviceaccount.com"
  cicd_sa    = "serviceAccount:postpilot-uat-cicd-deployer@glassy-storm-491011-q6.iam.gserviceaccount.com"
}

# 1. Grant Secret Manager access to GKE nodes
resource "google_project_iam_binding" "secret_accessor" {
  project = local.project_id
  role    = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${local.compute_sa}"
  ]
}

# 2. Grant Registry reader access to GKE nodes
resource "google_project_iam_binding" "registry_reader" {
  project = local.project_id
  role    = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${local.compute_sa}"
  ]
}

# 3. Grant Health Reporting to nodes (fixes degraded status)
resource "google_project_iam_binding" "node_health" {
  project = local.project_id
  role    = "roles/container.defaultNodeServiceAccount"
  members = [
    "serviceAccount:${local.compute_sa}"
  ]
}

# 4. Grant GKE Developer access to CICD Deployer
resource "google_project_iam_binding" "cicd_gke_dev" {
  project = local.project_id
  role    = "roles/container.developer"
  members = [
    local.cicd_sa
  ]
}
