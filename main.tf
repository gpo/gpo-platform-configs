terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.60"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  #############################################################
  ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  ## YOU WILL UNCOMMENT THIS CODE THEN RERUN TERRAFORM INIT
  ## TO SWITCH FROM LOCAL BACKEND TO REMOTE AWS BACKEND
  #############################################################
  # backend "s3" {
  #   bucket         = "gpo-terraform-state"
  #   key            = "03-basics/import-bootstrap/terraform.tfstate"
  #   region         = "ca-central-1"
  #   dynamodb_table = "terraform-state-locks"
  #   encrypt        = true
  # }
}
