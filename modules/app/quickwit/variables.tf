variable "name" {
  type        = string
  description = "A base name for quickwit resources."
  default     = "quickwit"
}

variable "environment" {
  type        = string
  description = "One of 'prod' or 'stage'."
}
