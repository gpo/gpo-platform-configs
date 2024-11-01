module "default_github_labels_for_secure_gpo_ca" {
  source     = "./default_github_labels_module"
  repository = "secure.gpo.ca"

  labels = [
    { name = "CiviCRM" },
    { name = "Drupal" },
  ]
}

module "default_github_labels_for_gpo_ca" {
  source     = "./default_github_labels_module"
  repository = "gpo.ca"
}

module "default_github_labels_for_readme" {
  source     = "./default_github_labels_module"
  repository = "readme"
}

module "default_github_labels_for_gpo_platform_configs" {
  source     = "./default_github_labels_module"
  repository = "gpo-platform-configs"
}

module "default_github_labels_for_gpo_it" {
  source     = "./default_github_labels_module"
  repository = "gpo-it"
}
