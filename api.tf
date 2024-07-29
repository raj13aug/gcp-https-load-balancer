## Enable the certificate manager API ##
resource "google_project_service" "certificate_manager" {
  service = "certificatemanager.googleapis.com"
}
