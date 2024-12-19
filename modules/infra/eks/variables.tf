variable "cluster_subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for the cluster to exist within."
}

variable "name" {
  type        = string
  description = "A base name for EKS resources."
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["prod", "stage"], var.environment)
    error_message = "Must be one of 'stage' or 'prod'."
  }
}
