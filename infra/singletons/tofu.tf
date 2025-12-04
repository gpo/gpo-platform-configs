terraform {
  required_providers {

    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }

    github = {
      source  = "integrations/github"
      version = "6.4.0"
    }

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.48.0"
    }
  }

  backend "gcs" {
    bucket = "gpo-tf-state-data"
    prefix = "infra/singletons"
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
