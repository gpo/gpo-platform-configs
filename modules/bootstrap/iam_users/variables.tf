variable "iam_admin_users" {
  type        = list(string)
  description = "List of IAM admin users to be created."
}

variable "iam_eks_users" {
  type        = list(string)
  description = "List of IAM eks users to be created."
}

variable "environment" {
  type        = string
  description = "One of 'prod' or 'stage'."
}
