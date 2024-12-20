module "default_github_labels_for_secure_gpo_ca" {
  source     = "../../modules/infra/github_default_labels"
  repository = github_repository.secure_gpo_ca.name

  labels = [
    { name = "CiviCRM" },
    { name = "Drupal" },
  ]
}

module "default_github_labels_for_gpo_ca" {
  source     = "../../modules/infra/github_default_labels"
  repository = "gpo.ca"

  labels = [
    { name = "Content" },
  ]
}

module "default_github_labels_for_readme" {
  source     = "../../modules/infra/github_default_labels"
  repository = "readme"
}

module "default_github_labels_for_gpo_platform_configs" {
  source     = "../../modules/infra/github_default_labels"
  repository = "gpo-platform-configs"
}

module "default_github_labels_for_gpo_it" {
  source     = "../../modules/infra/github_default_labels"
  repository = "gpo-it"
}
