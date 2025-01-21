terraform {
  required_providers {

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.46.1"
    }

    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.81"
    }
  }

  backend "s3" {
    bucket         = "gpo-terraform-state"
    key            = "infra/stage/terraform.tfstate"
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

provider "digitalocean" {
  token = data.sops_file.secrets.data["do_token"]
}
