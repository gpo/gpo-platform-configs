variable "environment" {
  type = string
  validation {
    condition     = contains(["prod", "stage"], var.environment)
    error_message = "must be one of 'stage' or 'prod'"
  }
}
