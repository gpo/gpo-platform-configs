data "sops_file" "secrets" {
  source_file = "../../../secrets.env"
}

data "sops_file" "environment_secrets" {
  source_file = "../../../secrets.stage.env"
}
