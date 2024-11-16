# staging

## test it here

This composition consists *only* of calls to modules, there should be NO
terraform resources here. We use the exact same modules in `stage` that we will
use in `prod`, the only difference is in the variables we pass.

The assumption is that we will `tofo plan` and `tofo apply` iteratively on a
branch in `stage` until we're happy with the results. A change which modifies
a module that is currently being used in `prod` must NOT be merged to `main`
until it is ready to be applied to `prod`. After merging to `main`, `prod`
must be applied to pick up the changes.
