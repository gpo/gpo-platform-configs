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

## Helper Script: tofu-all

A helper script `tofu-all` is available at the root of this repo. It allows you to run any `tofu` command (such as `init`, `apply`, etc.) in every directory containing a `tofu.tf` file.

### Usage

```sh
./tofu-all <command> [args...]
```

#### Examples

- Initialize all states:
  ```sh
  ./tofu-all init
  ```
- Apply all states with auto-approve:
  ```sh
  ./tofu-all apply -auto-approve
  ```

This will echo the directory and run the specified `tofu` command in each relevant directory.

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

## AWS Accounts

We have two primary AWS accounts for prod / stage, and we are primarily using the `ca-central-1` region.

Stage account ID 542371827759, [login](https://542371827759.signin.aws.amazon.com/console/)

Prod account ID 060795914812, [login](https://060795914812.signin.aws.amazon.com/console/)

### Profiles

AWS CLI access can be managed by using a ["credentials" file](https://docs.aws.amazon.com/cli/v1/userguide/cli-configure-files.html). Our tooling and scripts assumes the following profiles are present in the credentials file.

```ini
[gpo-stage] # account id 542371827759
aws_access_key_id = AKIA_YOUR_ACCESS_KEY_GOES_HERE
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_GOES_HERE

[gpo-prod] # account id 060795914812
aws_access_key_id = AKIA_YOUR_ACCESS_KEY_GOES_HERE
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY_GOES_HERE
```

### Users

User IAM accounts are managed in [bootstrap/locals.tf](bootstrap/locals.tf). Usernames added to the list of `iam_admin_users` become full AWS admins. Usernames added to the list of `iam_eks_users` become EKS admins. When adding a new user run the following to retrieve their temporary password:

```console
$ cd bootstrap && tofu output -json | jq '.user_creds.value'
```

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
