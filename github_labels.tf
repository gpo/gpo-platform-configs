module "default_github_labels_for_secure_gpo_ca" {
  source     = "./default_github_labels_module"
  repository = "secure.gpo.ca"
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
