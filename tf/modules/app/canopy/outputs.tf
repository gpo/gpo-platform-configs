output "hostname" {
  value = cloudflare_dns_record.canopy.name
}

output "db_gsm_secret_id" {
  /* we're doing this because we need to output this secret id so it can be consumed by the external secrets
     module, however if we try to output `google_secret_manager...id` and pass that to external secrets the
     apply fails due to this issue: https://discuss.hashicorp.com/t/the-for-each-value-depends-on-resource-attributes-that-cannot-be-determined-until-apply/25016
     so instead we just output a static string and get on with our lives
  */
  description = "ID of the secret in GSM where the Canopy DB connection info is stored."
  value       = local.secret_id
}
