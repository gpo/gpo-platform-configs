# staging

## test it here

This composition consists *only* of calls to modules, there should be NO terraform resources here. We use the exact same modules in `stage` that we will use in `prod`, the only difference is in the variables we pass.

It is expected that we will `tf plan` and `tf apply` iteratively on a branch in `stage` until we're happy with the results.

## WARNING

Changes to modules used in `prod` must NOT be merged until they're ready to be applied to `prod`! After merging to `main`, `prod` must be applied to pick up the changes.
