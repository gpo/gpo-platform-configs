# retrieve the outputs of the bootstrap TF so we can use them as inputs

data "terraform_remote_state" "bootstrap" {
  backend = "s3"
  config = {
    bucket         = "gpo-terraform-state"
    key            = "bootstrap/terraform.tfstate"
    region         = "ca-central-1"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
    profile        = "gpo-stage"
  }
}
