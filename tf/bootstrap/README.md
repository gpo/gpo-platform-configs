# bootstrapping a new GCP account

In the event we need to spin up infra in a brand new GCP account, we need to
do some manual stuff before we can run our TF.

```sh
PROJECT=gpo-tf-state-lives-here

BUCKET=a-unique-name-for-a-bucket-that-holds-tf-state-files

$ gcloud projects create ${PROJECT} --billing-account=BILLING_ACCOUNT_ID_GOES_HERE

$ gcloud storage buckets create gs://${BUCKET} --project ${PROJECT}
```

Then recursively update every `tofu.tf` and `remote_state.tf` file to reference the new bucket.
Once this is complete, TF can be applied.
