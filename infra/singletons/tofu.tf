terraform {
  required_providers {

    sops = {
      source  = "carlpett/sops"
      version = "~> 0.5"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "gpo-terraform-state"
    key            = "infra/singletons/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    profile        = "gpo-stage"
  }
}

# requires authorized gh
provider "github" {
  owner = "gpo"
}

provider "cloudflare" {
  email   = "ianedington@gpo.ca"
  api_key = data.sops_file.secrets.data["cloudflare_api_key"]
}
