variable "gcp_project_id" {
  type        = string
  description = "ID of the project in scope"
  default     = "mytesting-400910"
}

variable "region" {
  type        = string
  description = "default region"
  default     = "us-central1"
}