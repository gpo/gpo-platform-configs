# production

## don't break it

This composition consists *only* of calls to modules, there should be NO
terraform resources here. We use the exact same modules in `prod` that are tested in `stage`, the only difference is in the variables we pass.
