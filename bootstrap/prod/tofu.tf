terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81"
    }
  }

  backend "s3" {
    bucket         = "gpo-terraform-state-prod"
    key            = "bootstrap/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    profile        = "gpo-prod"
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "gpo-prod"
}
