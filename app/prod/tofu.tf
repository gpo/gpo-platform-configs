terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }

  }

  backend "s3" {
    bucket         = "gpo-terraform-state"
    key            = "app/prod/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    profile        = "gpo"
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "gpo"
}
