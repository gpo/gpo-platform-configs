data "sops_file" "secrets" {
  source_file = "../../secrets.env"
}
