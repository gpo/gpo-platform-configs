terraform {
  required_providers {

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "gpo-terraform-state"
    key            = "root/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}

# requires authorized gh
provider "github" {
  owner = "gpo"
}
