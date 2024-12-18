variable "repository" {
  description = "The name of the repository"
  type        = string
}

variable "labels" {
  description = "List of labels [{name, description, color?}]"
  type = list(object({
    name        = string
    description = optional(string)
    color       = optional(string)
  }))
  default = []
}
