module "drupal" {
  source      = "../../modules/app/drupal"
  environment = local.environment
}
