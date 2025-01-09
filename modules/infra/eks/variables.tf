# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group#scaling_config-configuration-block

variable "nodegroup_desired_size" {
  type        = number
  description = "Number of nodes there should be right now."
}

variable "nodegroup_min_size" {
  type        = number
  description = "Minimum number of nodes to have at any time."
}

variable "nodegroup_max_size" {
  type        = number
  description = "Maximum number of nodes to have at any time."
}

/*
Note: EKS clusters MUST be created with subnets in at least two AZs. Since
we only want this cluster to be in a single AZ we have "active" and "inactive"
subnets. We give EKS both subnets to satisfy it, but then we will only ever
create worker nodes in the active subnet.
*/

variable "private_active_subnet_ids" {
  type        = list(string)
  description = "List of active subnet IDs for the cluster."
}

variable "private_inactive_subnet_ids" {
  type        = list(string)
  description = "List of inactive subnet IDs for the cluster."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs for the cluster."
}

variable "admin_user_arns" {
  type        = list(string)
  description = "List of user ARNs who will get Admin access to the cluster."
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
