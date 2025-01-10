variable "name" {
  type        = string
  description = "A base name for VPC resources."
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["prod", "stage"], var.environment)
    error_message = "Must be one of 'stage' or 'prod'."
  }
}
