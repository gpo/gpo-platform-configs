/*
rob - commenting this out until i figure out what this bucket is actually for
module "drupal" {
  source      = "../../modules/app/drupal"
  environment = local.environment
}*/

module "legacy_logging" {
  source = "../../modules/app/legacy_logging"
}
