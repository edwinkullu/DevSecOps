terraform {
  backend "gcs" {
    # Bucket is provided via -backend-config during init
    prefix = "terraform/state/dev"
  }
}





