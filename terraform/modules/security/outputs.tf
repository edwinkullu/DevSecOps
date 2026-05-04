output "gke_sa_email" {
  description = "The email of the GKE application and node service account"
  value       = google_service_account.gke_sa.email
}

output "cicd_deployer_email" {
  description = "The email of the CI/CD deployer service account"
  value       = google_service_account.cicd_deployer.email
}
