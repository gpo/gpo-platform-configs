locals {
  environment       = "stage"
  canopy_db_tier    = "db-f1-micro"
  canopy_db_edition = "ENTERPRISE" // believe it or not, this is the cheap one
  /* gcp specific */
  region_toronto = "northamerica-northeast2"
  zone_toronto   = "northamerica-northeast2-a"
}
