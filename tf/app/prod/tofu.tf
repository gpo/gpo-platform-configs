terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.15.0"
    }

    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.46.1"
    }

    sops = {
      source  = "carlpett/sops"
      version = "0.7.2"
    }

    google = {
      source  = "hashicorp/google"
      version = "7.12.0"
    }

  }

  backend "gcs" {
    bucket = "gpo-tf-state-data"
    prefix = "prod/app"
  }
}

provider "digitalocean" {
  token = data.sops_file.secrets.data["do_token"]
}

provider "cloudflare" {
  email   = "ianedington@gpo.ca"
  api_key = data.sops_file.secrets.data["cloudflare_api_key"]
}

provider "google" {
  project = data.terraform_remote_state.bootstrap.outputs.gcp_project_gpo_eng.id
  alias   = "gpo_eng"
}
