variable "gcp_project" {
  description = "GCP project (note: not project number)"
  type        = string
  sensitive   = true
}

variable "gcp_region" {
  description = "GCP Region to hold resources."
  type        = string
}

variable "mysql_host" {
  description = "Host for CiviCRM MySQL database"
  type        = string
  sensitive   = true
}

variable "mysql_username" {
  description = "Username for CiviCRM MySQL database"
  type        = string
  sensitive   = true
}

variable "mysql_password" {
  description = "Password for CiviCRM MySQL database"
  type        = string
  sensitive   = true
}
