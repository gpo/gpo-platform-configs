terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81"
    }

    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }
  }

  backend "gcs" {
    bucket = "gpo-tf-state-data"
    prefix = "prod/bootstrap"
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "gpo-prod"
}
