## Enable the Cloud DNS API ##
resource "google_project_service" "cloud_dns" {
  service = "dns.googleapis.com"
}