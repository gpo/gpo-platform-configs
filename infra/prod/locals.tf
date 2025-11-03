locals {
  name        = "gpo" # broadly used as a prefix for resource names
  environment = "prod"
  /* gcp specific */
  region_toronto = "northamerica-northeast2"
  zone_toronto   = "northamerica-northeast2-a"
}
