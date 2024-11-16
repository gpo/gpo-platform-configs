module "default_github_labels_for_secure_gpo_ca" {
  source     = "../modules/github"
  repository = "secure.gpo.ca"

  labels = [
    { name = "CiviCRM" },
    { name = "Drupal" },
  ]
}

module "default_github_labels_for_gpo_ca" {
  source     = "../modules/github"
  repository = "gpo.ca"
}

module "default_github_labels_for_readme" {
  source     = "../modules/github"
  repository = "readme"
}

module "default_github_labels_for_gpo_platform_configs" {
  source     = "../modules/github"
  repository = "gpo-platform-configs"
}

module "default_github_labels_for_gpo_it" {
  source     = "../modules/github"
  repository = "gpo-it"
}
