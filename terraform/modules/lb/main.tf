# Global IP — one per environment
resource "google_compute_global_address" "ip" {
  name = "${var.name}-${var.environment}-ip"
  lifecycle {
    prevent_destroy = true
  }
}

/*
# URL Map (Skeleton — rules managed by K8s Ingress)
resource "google_compute_url_map" "map" {
  name = "${var.name}-${var.environment}-url-map"

  # Placeholder default redirect — overridden by GKE Ingress NEG rules
  default_url_redirect {
    https_redirect = true
    strip_query    = false
  }

  lifecycle {
    ignore_changes = [host_rule, path_matcher, default_service, default_url_redirect]
  }
}
*/

/*
# DNS Authorization for Wildcard
resource "google_certificate_manager_dns_authorization" "wildcard_auth" {
  name        = "${var.name}-${var.environment}-dns-auth"
  description = "DNS Authorization for *.${var.domain_name}"
  domain      = var.domain_name
}

# Certificate Manager
resource "google_certificate_manager_certificate" "wildcard_cert" {
  name        = "${var.name}-${var.environment}-ssl-cert"
  description = "Wildcard certificate for *.${var.domain_name}"
  location    = "global"
  managed {
    domains = ["*.${var.domain_name}"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.wildcard_auth.id
    ]
  }
  lifecycle {
    ignore_changes = [managed[0].dns_authorizations]
  }
}
*/

resource "google_certificate_manager_certificate_map" "map" {
  name = "${var.name}-${var.environment}-cert-map"
}

resource "google_certificate_manager_certificate_map_entry" "wildcard_entry" {
  name         = "wildcard-entry"
  map          = google_certificate_manager_certificate_map.map.name
  # Pointing to the manually managed certificate (pattern: uat-ssl-cert or prod-ssl-cert)
  certificates = ["projects/${var.project_id}/locations/global/certificates/${var.environment}-ssl-cert"]
  hostname     = "*.${var.domain_name}"
}

resource "google_certificate_manager_certificate_map_entry" "apex_entry" {
  name         = "apex-entry"
  map          = google_certificate_manager_certificate_map.map.name
  certificates = ["projects/${var.project_id}/locations/global/certificates/${var.environment}-ssl-cert"]
  hostname     = var.domain_name
}



/*
# HTTPS Proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name            = "${var.name}-${var.environment}-https-proxy"
  url_map         = google_compute_url_map.map.self_link
  certificate_map = "//certificatemanager.googleapis.com/${google_certificate_manager_certificate_map.map.id}"
}
*/

/*
# Forwarding Rule
resource "google_compute_global_forwarding_rule" "https_rule" {
  name                  = "${var.name}-${var.environment}-https-rule"
  target                = google_compute_target_https_proxy.https_proxy.self_link
  port_range            = "443-443"
  ip_address            = google_compute_global_address.ip.address
  load_balancing_scheme = "EXTERNAL_MANAGED"
}
*/

# --- CLOUD ARMOR: Security Policy (WAF / DDoS) ---
resource "google_compute_security_policy" "policy" {
  name = "${var.name}-${var.environment}-security-policy"

  # Default rule: ALLOW
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow rule"
  }

  # Rate limiting to prevent LLM API abuse
  rule {
    action   = "throttle"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      rate_limit_threshold {
        count        = 500
        interval_sec = 60
      }
    }
    description = "Rate limiting for API protection"
  }
}
