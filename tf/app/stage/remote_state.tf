# retrieve the outputs of the infra & bootstrap TF so we can use them as inputs

data "terraform_remote_state" "infra" {
  backend = "gcs"
  config = {
    bucket = "gpo-tf-state-data"
    prefix = "stage/infra"
  }
}

data "terraform_remote_state" "bootstrap" {
  backend = "gcs"
  config = {
    bucket = "gpo-tf-state-data"
    prefix = "stage/bootstrap"
  }
}
