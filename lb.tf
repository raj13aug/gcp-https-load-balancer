# Load balancer IP
resource "google_compute_global_address" "lb_ip_address" {
  name        = "example-lb-ip"
  description = "Public IP address of the Global HTTPS load balancer"
}

## Global load balancer DNS records ##
resource "google_dns_record_set" "global_load_balancer_sub_domain" {
  managed_zone = data.google_dns_managed_zone.cloudroot.name
  name         = "*.${data.google_dns_managed_zone.cloudroot.dns_name}"
  type         = "A"
  rrdatas      = [google_compute_global_address.lb_ip_address.address]
}

resource "google_dns_record_set" "global_load_balancer_top_level_domain" {
  managed_zone = data.google_dns_managed_zone.cloudroot.name
  name         = data.google_dns_managed_zone.cloudroot.dns_name
  type         = "A"
  rrdatas      = [google_compute_global_address.lb_ip_address.address]
}


# HTTPS load balancer
resource "google_compute_global_forwarding_rule" "https_forwarding_rule" {
  name        = "https-forwarding-rule"
  description = "Global external load balancer"
  ip_address  = google_compute_global_address.lb_ip_address.id
  port_range  = "443"
  target      = google_compute_target_https_proxy.https_proxy.self_link
}

# HTTPS proxy
resource "google_compute_target_https_proxy" "https_proxy" {
  name            = "https-webserver-proxy"
  description     = "HTTPS Proxy mapping for the Load balancer including wildcard ssl certificate"
  url_map         = google_compute_url_map.url_map.self_link
  certificate_map = "//${google_project_service.certificate_manager.service}/${google_certificate_manager_certificate_map.certificate_map.id}"
}

# HTTP proxy
resource "google_compute_global_forwarding_rule" "http_forwarding_rule" {
  name        = "http-forwarding-rule"
  description = "Global external load balancer HTTP redirect"
  ip_address  = google_compute_global_address.lb_ip_address.id
  port_range  = "80"
  target      = google_compute_target_http_proxy.http_proxy.self_link
}

## HTTPS redirect proxy
resource "google_compute_target_http_proxy" "http_proxy" {
  name        = "http-webserver-proxy"
  description = "Redirect proxy mapping for the Load balancer"
  url_map     = google_compute_url_map.http_https_redirect.self_link
}

# Default URL map
resource "google_compute_url_map" "url_map" {
  name        = "url-map"
  description = "Url mapping to the backend services"
}

# Redirect URL map
resource "google_compute_url_map" "http_https_redirect" {
  name        = "http-https-redirect"
  description = "HTTP Redirect map"

  default_url_redirect {
    https_redirect         = true
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT"
    strip_query            = false
  }
}