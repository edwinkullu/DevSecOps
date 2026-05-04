resource "google_api_gateway_api" "api" {
  provider = google-beta
  api_id   = "${var.name_prefix}-${var.api_id}"
  project  = var.project_id
}

resource "google_api_gateway_api_config" "api_config" {
  provider     = google-beta
  api           = google_api_gateway_api.api.api_id
  api_config_id = "${var.name_prefix}-${var.api_id}-config"
  project      = var.project_id

  openapi_documents {
    document {
      path     = "spec.yaml"
      contents = base64encode(<<-EOF
swagger: '2.0'
info:
  title: Default API
  version: 1.0.0
paths:
  /ping:
    get:
      summary: Ping
      operationId: ping
      x-google-backend:
        address: https://example.com  # Placeholder backend address
      responses:
        '200':
          description: OK
EOF
      )
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_api_gateway_gateway" "gateway" {
  provider   = google-beta
  gateway_id = "${var.name_prefix}-gateway"
  api_config = google_api_gateway_api_config.api_config.id
  region     = var.region
  project    = var.project_id
}
