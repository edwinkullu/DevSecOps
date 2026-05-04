output "gateway_url" {
  description = "The default host name of the API Gateway."
  value       = google_api_gateway_gateway.gateway.default_hostname
}

output "api_id" {
  description = "The ID of the generated API"
  value       = google_api_gateway_api.api.api_id
}
