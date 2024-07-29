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
