
## Configure DNS authorization to provide the ACME challenge DNS records ##
resource "google_certificate_manager_dns_authorization" "dns_authorization" {
  name        = "dns-authorization"
  description = "DNS authorization for example.com to support wildcard certificates"
  domain      = "cloudroot7.xyz"
}

## Provision a wildcard managed SSL certificate using DNS authorization ##
resource "google_certificate_manager_certificate" "wildcard_ssl_certificate" {
  name        = "wildcard-ssl-certificate"
  description = "Wildcard certificate for cloudroot7.xyz and sub-domains"

  managed {
    domains = ["cloudroot7.xyz", "*.cloudroot7.xyz"]
    dns_authorizations = [
      google_certificate_manager_dns_authorization.dns_authorization.id
    ]
  }
}

## Certificate map resource to reference to from a forwarding rule ##
resource "google_certificate_manager_certificate_map" "certificate_map" {
  name        = "certificate-map"
  description = "cloudroot7.xyz certificate map containing the domain names and sub-domains names for the SSL certificate"
}

## Certificate map entry for the top-level domain ##
resource "google_certificate_manager_certificate_map_entry" "domain_certificate_entry" {
  name         = "domain-cert-entry"
  description  = "cloudroot7.xyz certificate entry"
  map          = google_certificate_manager_certificate_map.certificate_map.name
  certificates = [google_certificate_manager_certificate.wildcard_ssl_certificate.id]
  hostname     = "cloudroot7.xyz"
}

## Certificate map entry for the sub domain
resource "google_certificate_manager_certificate_map_entry" "sub_domain_certificate_entry" {
  name         = "sub-domain-entry"
  description  = "*.cloudroot7.xyz certificate entry"
  map          = google_certificate_manager_certificate_map.certificate_map.name
  certificates = [google_certificate_manager_certificate.wildcard_ssl_certificate.id]
  hostname     = "*.cloudroot7.xyz"
}

# DNS authorization record ##
resource "google_dns_record_set" "dns_authorization_wildcard_certificate" {
  name         = google_certificate_manager_dns_authorization.dns_authorization.dns_resource_record[0].name
  managed_zone = data.google_dns_managed_zone.cloudroot.name
  type         = google_certificate_manager_dns_authorization.dns_authorization.dns_resource_record[0].type
  ttl          = 300
  rrdatas      = [google_certificate_manager_dns_authorization.dns_authorization.dns_resource_record[0].data]
} #