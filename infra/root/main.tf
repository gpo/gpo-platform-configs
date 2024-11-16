module "default_github_labels_for_secure_gpo_ca" {
  source     = "../../modules/infra/github"
  repository = "secure.gpo.ca"

  labels = [
    { name = "CiviCRM" },
    { name = "Drupal" },
  ]
}

module "github" {
  source = "../../modules/infra/github"
}
