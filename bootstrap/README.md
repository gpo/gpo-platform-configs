# bootstrap

## apply once at the beginning of terraform adoption, then ignore.

Sets up the bucket and DDB table for the rest of the TF state to exist in.

## disaster recovery

If we need to create a net new environment:

1. create new AWS account - update aws profile `gpo` with new creds
1. comment out the `backend` section in `tofu.tf`
1. update `main.tf` with a new bucket name (bucket names must be unique across ALL AWS accounts)
1. `tf apply`
1. `aws --profile gpo s3 cp terraform.tfstate s3://<new-bucket-name>/bootstrap/terraform.tfstate`
1. uncomment the `backend` section in tofu.tf and update it to reflect the new bucket name
1. move your local tfstate file out of the way for a moment: `mv terraform.tfstate /tmp`
1. ensure `tf plan` both:
  * fetches remote state from the new bucket successfully
  * doesn't want to change anything
1. remove your local copy of the state file `rm /tmp/terraform.tfstate`

You are now bootstrapped. Every other composition in this repo now needs the bucket name it its `backend` section of `tofu.tf` updated to reflect the new bucket name before we can run `tf apply`.
