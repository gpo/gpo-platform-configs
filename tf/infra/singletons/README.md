# terraform singletons

This composition contains resources which we have exactly one of, eg. github
org, aws accounts, domain registrations, etc. Put another way, anything which
will *not* have a separate copy for stage and prod belongs here.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | 4.48.0 |
| <a name="requirement_github"></a> [github](#requirement\_github) | 6.4.0 |
| <a name="requirement_sops"></a> [sops](#requirement\_sops) | 0.7.2 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | 4.0.6 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_cloudflare"></a> [cloudflare](#provider\_cloudflare) | 4.48.0 |
| <a name="provider_github"></a> [github](#provider\_github) | 6.4.0 |
| <a name="provider_sops"></a> [sops](#provider\_sops) | 0.7.2 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.6 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_default_github_labels_for_gpo_ca"></a> [default\_github\_labels\_for\_gpo\_ca](#module\_default\_github\_labels\_for\_gpo\_ca) | ../../modules/infra/github_default_labels | n/a |
| <a name="module_default_github_labels_for_gpo_it"></a> [default\_github\_labels\_for\_gpo\_it](#module\_default\_github\_labels\_for\_gpo\_it) | ../../modules/infra/github_default_labels | n/a |
| <a name="module_default_github_labels_for_gpo_platform_configs"></a> [default\_github\_labels\_for\_gpo\_platform\_configs](#module\_default\_github\_labels\_for\_gpo\_platform\_configs) | ../../modules/infra/github_default_labels | n/a |
| <a name="module_default_github_labels_for_public"></a> [default\_github\_labels\_for\_public](#module\_default\_github\_labels\_for\_public) | ../../modules/infra/github_default_labels | n/a |
| <a name="module_default_github_labels_for_secure_gpo_ca"></a> [default\_github\_labels\_for\_secure\_gpo\_ca](#module\_default\_github\_labels\_for\_secure\_gpo\_ca) | ../../modules/infra/github_default_labels | n/a |
| <a name="module_islandgetaway_ca_no_email"></a> [islandgetaway\_ca\_no\_email](#module\_islandgetaway\_ca\_no\_email) | ../../modules/infra/no_email_dns | n/a |
| <a name="module_ontariogreens_ca_no_email"></a> [ontariogreens\_ca\_no\_email](#module\_ontariogreens\_ca\_no\_email) | ../../modules/infra/no_email_dns | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [cloudflare_bot_management.gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/bot_management) | resource |
| [cloudflare_origin_ca_certificate.gpo_ca_origin](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/origin_ca_certificate) | resource |
| [cloudflare_pages_domain.april_fools_1997_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/pages_domain) | resource |
| [cloudflare_pages_domain.islandgetaway_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/pages_domain) | resource |
| [cloudflare_pages_project.april_fools](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/pages_project) | resource |
| [cloudflare_pages_project.islandgetaway](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/pages_project) | resource |
| [cloudflare_pages_project.maintenance](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/pages_project) | resource |
| [cloudflare_record._1997_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record._28200265_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record._28264590_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record._dmarc_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record._gh_gpo_o_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.agmsurvey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.brevo1__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.brevo2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.brevo_code2_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.brevo_code3_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.brevo_code_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.e1_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.e2_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.e_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.emailing_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.facebook_domain_verification_ontariogreens_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.facebook_secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.feb2019__domainkey_lists_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.files_ontariogreens_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.google__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.google_domainkey_mikeforguelph_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.google_secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.google_site_verification_mikeforguelph_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.islandgetaway_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.list_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mail__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mar2019__domainkey_lists_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mikeforguelph_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mx_alt1_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mx_alt2_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mx_aspmx2_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mx_aspmx3_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mx_aspmx_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.mx_mikeforguelph_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.o1_list_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.ontariogreens_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.return_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.s1__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.s2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.scph0219__domainkey_presslist_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.scph1018__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.scph1018__domainkey_spark_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.sg2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.sg__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.sgr2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.sgr__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.sgw__domainkey_e_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.spark_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.spf_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.spf_mikeforguelph_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.spf_web_e_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.staging_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.staging_secure_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.strong1__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.strong2__domainkey_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.web_e_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.www_gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.www_islandgetaway_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.www_mikeforguelph_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_record.www_ontariogreens_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/record) | resource |
| [cloudflare_ruleset.gpo_ca_admin_route_protection](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/ruleset) | resource |
| [cloudflare_ruleset.gpo_ca_wp_login_rate_limit](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/ruleset) | resource |
| [cloudflare_ruleset.ontariogreens_ca_redirect](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/ruleset) | resource |
| [cloudflare_ruleset.www_gpo_ca_redirect](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/ruleset) | resource |
| [cloudflare_ruleset.www_islandgetaway_ca_redirect](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/ruleset) | resource |
| [cloudflare_zero_trust_access_application.islandgetaway_previews](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/zero_trust_access_application) | resource |
| [cloudflare_zero_trust_access_policy.islandgetaway_previews_allow_gpo](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/zero_trust_access_policy) | resource |
| [cloudflare_zone.gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/zone) | resource |
| [cloudflare_zone.islandgetaway_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/zone) | resource |
| [cloudflare_zone.mikeforguelph_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/zone) | resource |
| [cloudflare_zone.ontariogreens_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/zone) | resource |
| [cloudflare_zone_settings_override.gpo_ca](https://registry.terraform.io/providers/cloudflare/cloudflare/4.48.0/docs/resources/zone_settings_override) | resource |
| [github_actions_secret.gpo_ca_ssh_host_prod1](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_ssh_host_stage](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_ssh_private_key](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_ssh_public_key](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.gpo_ca_ssh_user](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.secure_gpo_ca_ssh_host_prod](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.secure_gpo_ca_ssh_host_stage](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.secure_gpo_ca_ssh_private_key](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.secure_gpo_ca_ssh_public_key](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_actions_secret.secure_gpo_ca_ssh_user](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/actions_secret) | resource |
| [github_branch_default.civicrm_api](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.dot_github](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.gpo_ca](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.gpo_it](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.gpo_platform_configs](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.maintenance](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.migrate_bitbucket_to_github](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.open_walk_sheets](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.public](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_branch_default.secure_gpo_ca](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/branch_default) | resource |
| [github_repository.cdn_tax_receipts](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.civicrm_api](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.dot_github](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.gpo_ca](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.gpo_it](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.gpo_platform_configs](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.maintenance](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.migrate_bitbucket_to_github](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.open_walk_sheets](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.public](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [github_repository.secure_gpo_ca](https://registry.terraform.io/providers/integrations/github/6.4.0/docs/resources/repository) | resource |
| [tls_cert_request.gpo_ca_origin](https://registry.terraform.io/providers/hashicorp/tls/4.0.6/docs/resources/cert_request) | resource |
| [tls_private_key.gpo_ca_origin](https://registry.terraform.io/providers/hashicorp/tls/4.0.6/docs/resources/private_key) | resource |
| [sops_file.secrets](https://registry.terraform.io/providers/carlpett/sops/0.7.2/docs/data-sources/file) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudflare_zone_id"></a> [cloudflare\_zone\_id](#output\_cloudflare\_zone\_id) | Cloudflare zone ID. Used by other TF infra layers that need to provision DNS records. |
| <a name="output_gpo_ca_origin_certificate_pem"></a> [gpo\_ca\_origin\_certificate\_pem](#output\_gpo\_ca\_origin\_certificate\_pem) | Origin CA certificate for proxied gpo.ca hostnames. Installed by scripts/install-origin-cert.sh. |
| <a name="output_gpo_ca_origin_private_key_pem"></a> [gpo\_ca\_origin\_private\_key\_pem](#output\_gpo\_ca\_origin\_private\_key\_pem) | Private key for gpo\_ca\_origin\_certificate\_pem. Installed by scripts/install-origin-cert.sh. |
| <a name="output_mikeforguelph_ca_name_servers"></a> [mikeforguelph\_ca\_name\_servers](#output\_mikeforguelph\_ca\_name\_servers) | Cloudflare nameservers to set at the mikeforguelph.ca registrar (Namespro). |
<!-- END_TF_DOCS -->
