variable "project" {
  type        = string
  description = "GCP project in which to create the membership"
}

variable "user" {
  type        = string
  description = "User to give the membership to."
}
