# gpo-platform-configs
Infrastructure as Code for the GPO

This repo is WIP. It goes along with a design proposal to adopt Terraform.

Design Doc:
https://docs.google.com/document/d/1-2-MSpd-g_i5UjxHVkZW8wpKUZORjLrzd8A-UhW2XAY/edit


# Requirements

* `gh` with an authenticated session
* aws environment variables: AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY

# Development

## Install Dependencies

- Open Tofu: https://opentofu.org/docs/intro/install/
- pre-commit: https://pre-commit.com/#installation

## set up environment

1. run `tofu init`
1. run `pre-commit install`
1. `export PCT_TFPATH=$(which tofu)`

# Auto Generated Docs
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.60 |
| <a name="requirement_digitalocean"></a> [digitalocean](#requirement\_digitalocean) | ~> 2.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.65.0 |
| <a name="provider_digitalocean"></a> [digitalocean](#provider\_digitalocean) | 2.40.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.3 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_default_github_labels_for_gpo_ca"></a> [default\_github\_labels\_for\_gpo\_ca](#module\_default\_github\_labels\_for\_gpo\_ca) | ./default_github_labels_module | n/a |
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
| [digitalocean_spaces_bucket.drupal](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket) | resource |
| [digitalocean_spaces_bucket_policy.example_policy](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs/resources/spaces_bucket_policy) | resource |
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
