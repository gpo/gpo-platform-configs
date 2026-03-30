variable "april_fools_redirect_enabled" {
  type        = bool
  description = "When true, enables the April Fools redirect from gpo.ca/* to https://1997.gpo.ca (302). Set to true manually on April 1; leave false by default."
  default     = false
}
