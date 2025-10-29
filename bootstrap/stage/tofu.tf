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

  backend "s3" {
    bucket         = "gpo-terraform-state"
    key            = "bootstrap/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    profile        = "gpo-stage"
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "gpo-stage"
}
