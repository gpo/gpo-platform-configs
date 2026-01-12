terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.12.0"
    }
  }

  backend "gcs" {
    bucket = "gpo-tf-state-data"
    prefix = "stage/bootstrap"
  }
}

provider "google" {
  project = "gpo-bootstrap-2"
  alias   = "bootstrap"
}
