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

Containers resources which staging appls consume.

## [app/prod](./app/prod)

Containers resources which production apps consume.

### Rationale

This layout offers some desireable features:

* It is extremely difficult to accidentally apply the wrong thing. You don't have to remember to switch to the correct workspace, or export the right environment varaibles. All these things are hard coded into each composition.

* By using the _exact_ same modules (and NO resources) in stage/prod we increase confidence that what we test in stage will be what we get in prod.

### Current Limitations
- all state is in a single s3 bucket in aws prod acct


# Auto Generated Docs
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.60 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 4.0 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.65.0 |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.47.0 |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.40.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_default_github_labels_for_gpo_ca"></a> [default\_github\_labels\_for\_gpo\_ca](#module\_default\_github\_labels\_for\_gpo\_ca) | ./default_github_labels_module | n/a |
| <a name="module_default_github_labels_for_gpo_it"></a> [default\_github\_labels\_for\_gpo\_it](#module\_default\_github\_labels\_for\_gpo\_it) | ./default_github_labels_module | n/a |
| <a name="module_default_github_labels_for_gpo_platform_configs"></a> [default\_github\_labels\_for\_gpo\_platform\_configs](#module\_default\_github\_labels\_for\_gpo\_platform\_configs) | ./default_github_labels_module | n/a |
| <a name="module_default_github_labels_for_readme"></a> [default\_github\_labels\_for\_readme](#module\_default\_github\_labels\_for\_readme) | ./default_github_labels_module | n/a |
| <a name="module_default_github_labels_for_secure_gpo_ca"></a> [default\_github\_labels\_for\_secure\_gpo\_ca](#module\_default\_github\_labels\_for\_secure\_gpo\_ca) | ./default_github_labels_module | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_state_locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state_crypto_conf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [cloudflare_record._28200265_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record._28264590_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record._dmarc_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.agmsurvey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.dev_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.dev_secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.e1_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.e2_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.e_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.emailing2_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.emailing_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.facebook_secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.feb2019__domainkey_lists_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.google__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.google_secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.gvote_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.gvotedoworkaround_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.list_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.mail__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.mail_dev_secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.mar2019__domainkey_lists_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.mx_alt1_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.mx_alt2_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.mx_aspmx2_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.mx_aspmx3_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.mx_aspmx_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.o1_list_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.return_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.s1__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.s2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.scph0219__domainkey_presslist_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.scph1018__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.scph1018__domainkey_spark_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.secure_apps_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.secure_auth_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.sg2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.sg__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.sgr2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.sgr__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.sgw__domainkey_e_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.spark_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.spf_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.spf_web_e_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.staging_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.staging_secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.strong1__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.strong2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.web_e_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_record.www_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record) | resource |
| [cloudflare_zone.gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/zone) | resource |
| [digitalocean_spaces_bucket.drupal](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket) | resource |
| [github_actions_secret.SSH_HOST_PROD](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.SSH_HOST_STAGE](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.SSH_PRIVATE_KEY](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.SSH_PUBLIC_KEY](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.SSH_USER](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_SSH_HOST_PROD1](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_SSH_HOST_PROD2](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_SSH_HOST_STAGE](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_SSH_PRIVATE_KEY](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_SSH_PUBLIC_KEY](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_SSH_USER](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudflare_account_id"></a> [cloudflare\_account\_id](#input\_cloudflare\_account\_id) | Cloudflare account ID | `string` | n/a | yes |
| <a name="input_cloudflare_api_key"></a> [cloudflare\_api\_key](#input\_cloudflare\_api\_key) | Cloudflare API key | `string` | n/a | yes |
| <a name="input_do_spaces_access_id"></a> [do\_spaces\_access\_id](#input\_do\_spaces\_access\_id) | Digital Ocean Spaces Access ID | `string` | n/a | yes |
| <a name="input_do_spaces_secret_key"></a> [do\_spaces\_secret\_key](#input\_do\_spaces\_secret\_key) | Digital Ocean Spaces Secret Key | `string` | n/a | yes |
| <a name="input_do_token"></a> [do\_token](#input\_do\_token) | Digital Ocean Token | `string` | n/a | yes |
| <a name="input_prod1_ip_address"></a> [prod1\_ip\_address](#input\_prod1\_ip\_address) | Prod1 server IP address | `string` | n/a | yes |
| <a name="input_prod2_ip_address"></a> [prod2\_ip\_address](#input\_prod2\_ip\_address) | Prod2 server IP address | `string` | n/a | yes |
| <a name="input_ssh_private_key"></a> [ssh\_private\_key](#input\_ssh\_private\_key) | SSH private key | `string` | n/a | yes |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | SSH public key | `string` | n/a | yes |
| <a name="input_ssh_user"></a> [ssh\_user](#input\_ssh\_user) | SSH user for gpo.ca | `string` | n/a | yes |
| <a name="input_staging_ip_address"></a> [staging\_ip\_address](#input\_staging\_ip\_address) | staging server IP address | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
