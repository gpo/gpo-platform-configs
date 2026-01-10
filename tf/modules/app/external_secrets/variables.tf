variable "secrets" {
  description = "List of secrets that External Secrets should get access to. Secrets passed in this variable are all managed INSIDE of TF."
  type        = list(string)
}
