# gpo-platform-configs
Infrastructure as Code for the GPO

This repo is WIP. It goes along with a design proposal to adopt Terraform.

Design Doc:
https://docs.google.com/document/d/1-2-MSpd-g_i5UjxHVkZW8wpKUZORjLrzd8A-UhW2XAY/edit


# Requirements

* `gh` with an authenticated session
* aws profile called `gpo`

# Development

## Install Dependencies

- Open Tofu: https://opentofu.org/docs/intro/install/
- pre-commit: https://pre-commit.com/#installation
- SOPS: https://getsops.io/docs/#stable-release

## set up environment

1. run `tofu init`
1. run `pre-commit install`
1. `export PCT_TFPATH=$(which tofu)`

## Adding Secrets

1. ensure your favorite editor is exported: `EDITOR=emacs`
1. run `sops edit secrets.env'
1. commit changes

# Organization

This repo is organized into multiple TF states (AKA "stacks" AKA "compositions"), which is to say that you can run `tf apply` in each of these directories.

## [bootstrap](./bootstrap)

Contains resources for bootstrapping TF.

## [infra/singletons](./infra/singletons)

Contains resources we only have one of.

## [infra/stage](./infra/stage)

Contains staging infrastructure on which staging apps run.

## [infra/prod](./infra/prod)

Contains production infrastructure on which production apps run.

## [app/stage](./app/stage)

Contains resources which staging apps consume.

## [app/prod](./app/prod)

Contains resources which production apps consume.

### Rationale

This layout offers some desireable features:

* It is extremely difficult to accidentally apply the wrong thing. You don't have to remember to switch to the correct workspace, or export the right environment varaibles. All these things are hard coded into each composition.

* By using the _exact_ same modules (and NO resources) in stage/prod we increase confidence that what we test in stage will be what we get in prod.

### Current Limitations
- all state is in a single s3 bucket in aws prod acct


# Auto Generated Docs
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
