terraform {
  required_providers {

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.48.0"
    }

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

    google = {
      source  = "hashicorp/google"
      version = "6.8.0"
    }

  }

  backend "gcs" {
    bucket = "gpo-tf-state-data"
    prefix = "stage/infra"
  }
}

provider "aws" {
  region  = "ca-central-1"
  profile = "gpo-stage"
}

provider "cloudflare" {
  email   = "ianedington@gpo.ca"
  api_key = data.sops_file.secrets.data["cloudflare_api_key"]
}

provider "digitalocean" {
  token = data.sops_file.secrets.data["do_token"]
}

provider "google" {
  project = data.terraform_remote_state.bootstrap.outputs.gcp_project_gpo_eng.project_id
  alias   = "gpo_eng"
}
