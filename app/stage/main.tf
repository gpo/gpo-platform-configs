module "quickwit" {
  source      = "../../modules/app/quickwit"
  environment = local.environment
}
