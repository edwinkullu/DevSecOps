resource "google_compute_disk" "default" {
  count = var.itemCount
  name  = "${var.disk_prefix}-${count.index}"
  type  = var.disk_type
  zone  = var.zone
  size  = var.disk_size_gb
  labels = {
    environment = var.environment
  }
}