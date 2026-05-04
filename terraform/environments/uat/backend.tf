terraform {
  backend "gcs" {
    # All values (bucket, prefix, impersonate_service_account) 
    # will be provided via -backend-config during 'terraform init'
  }
}
