# retrieve the outputs of the bootstrap TF so we can use them as inputs

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "gpo-tf-state-data"
    prefix = "prod/bootstrap"
  }
}
