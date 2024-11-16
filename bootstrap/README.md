# bootstrap

## apply once at the beginning of terraform adoption, then ignore.

Sets up the bucket and DDB table for the rest of the TF state to exist in. Run
once and then manually copy the local `terraform.tfstate` file into the bucket
and uncomment the `remote_state` section of `terraform.tf`.

If we need to create a net new environment, comment out the `remote_state`
section and start again.
