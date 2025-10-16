# apps

## resources that a specific app requires (database, s3 bucket, DNS record, etc)

## GCP parallelism issue

`tofu apply` must be run with parallelism set to a low value so that resources apply without error (otherwise GCP returns 429s that cause the apply step to fail).

Example:

```
tofu apply -parallelism=1
```

When it's progressing too fast, you'll see errors like this from some GCP resources:

```
Error: Error creating Config: googleapi: Error 400: Precondition check failed.
```

You can set the `TF_LOG` env var to "debug" to see more info about the errors when this happens. For example, you'll see the underlying 429 errors.

They look like this:

```
2025-10-16T14:26:03.185-0400 [DEBUG] provider.terraform-provider-google: HTTP/2.0 429 Too Many Requests
...
2025-10-16T14:26:03.185-0400 [DEBUG] provider.terraform-provider-google: {
2025-10-16T14:26:03.185-0400 [DEBUG] provider.terraform-provider-google:   "error": {
2025-10-16T14:26:03.185-0400 [DEBUG] provider.terraform-provider-google:     "code": 429,
2025-10-16T14:26:03.185-0400 [DEBUG] provider.terraform-provider-google:     "message": "Resource has been exhausted (e.g. check quota).",
2025-10-16T14:26:03.185-0400 [DEBUG] provider.terraform-provider-google:     "status": "RESOURCE_EXHAUSTED"
2025-10-16T14:26:03.185-0400 [DEBUG] provider.terraform-provider-google:   }
2025-10-16T14:26:03.185-0400 [DEBUG] provider.terraform-provider-google: }
```
