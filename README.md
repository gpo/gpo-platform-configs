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

1. run pre-commit init
1. `export PCT_TFPATH=$(which tofu)`


```
tofu init
pre-commit install
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.60 |
| <a name="requirement_github"></a> [github](#requirement\_github) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.60.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 6.2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_dynamodb_table.terraform_state_locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state_crypto_conf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [github_actions_secret.SSH_HOST_PROD](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.SSH_HOST_STAGE](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.SSH_PRIVATE_KEY](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.SSH_PUBLIC_KEY](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_actions_secret.SSH_USER](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/actions_secret) | resource |
| [github_issue_labels.secure_gpo_ca](https://registry.terraform.io/providers/integrations/github/latest/docs/resources/issue_labels) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_secure_gpo_ca_prod_secret_ssh_host"></a> [secure\_gpo\_ca\_prod\_secret\_ssh\_host](#input\_secure\_gpo\_ca\_prod\_secret\_ssh\_host) | SSH host for secure.gpo.ca | `string` | n/a | yes |
| <a name="input_secure_gpo_ca_secret_ssh_private_key"></a> [secure\_gpo\_ca\_secret\_ssh\_private\_key](#input\_secure\_gpo\_ca\_secret\_ssh\_private\_key) | SSH private key for secure.gpo.ca | `string` | n/a | yes |
| <a name="input_secure_gpo_ca_secret_ssh_public_key"></a> [secure\_gpo\_ca\_secret\_ssh\_public\_key](#input\_secure\_gpo\_ca\_secret\_ssh\_public\_key) | SSH public key for secure.gpo.ca | `string` | n/a | yes |
| <a name="input_secure_gpo_ca_secret_ssh_user"></a> [secure\_gpo\_ca\_secret\_ssh\_user](#input\_secure\_gpo\_ca\_secret\_ssh\_user) | SSH user for secure.gpo.ca | `string` | n/a | yes |
| <a name="input_secure_gpo_ca_stage_secret_ssh_host"></a> [secure\_gpo\_ca\_stage\_secret\_ssh\_host](#input\_secure\_gpo\_ca\_stage\_secret\_ssh\_host) | SSH host for secure.gpo.ca | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
