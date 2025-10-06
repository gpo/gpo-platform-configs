provider "google" {
  project = var.gcp_project
  region  = local.region
}

locals {
  region = "northamerica-northeast2"

  # These are all the tables that existed in the civicrm database in staging as
  # of Sept 29th. We will assume all of these tables exist in production too
  # and that there are no tables in production that weren't in staging too as
  # of this date. We can also automate this more later so that we automatically
  # create a transfer config via Terraform for each CiviCRM-related table.
  civicrm_tables = [
    "cdntaxreceipts_log",
    "cdntaxreceipts_log_contributions",
    "civicrm_acl",
    "civicrm_acl_cache",
    "civicrm_acl_contact_cache",
    "civicrm_acl_entity_role",
    "civicrm_action_log",
    "civicrm_action_schedule",
    "civicrm_activity",
    "civicrm_activity_contact",
    "civicrm_address",
    "civicrm_address_format",
    "civicrm_afform_submission",
    "civicrm_batch",
    "civicrm_cache",
    "civicrm_campaign",
    "civicrm_campaign_group",
    "civicrm_case",
    "civicrm_case_activity",
    "civicrm_case_contact",
    "civicrm_case_type",
    "civicrm_cdntaxreceipts",
    "civicrm_component",
    "civicrm_contact",
    "civicrm_contact_type",
    "civicrm_contribution",
    "civicrm_contribution_page",
    "civicrm_contribution_product",
    "civicrm_contribution_recur",
    "civicrm_contribution_soft",
    "civicrm_contribution_widget",
    "civicrm_country",
    "civicrm_county",
    "civicrm_currency",
    "civicrm_custom_field",
    "civicrm_custom_group",
    "civicrm_cxn",
    "civicrm_dashboard",
    "civicrm_dashboard_contact",
    "civicrm_dedupe_exception",
    "civicrm_dedupe_rule",
    "civicrm_dedupe_rule_group",
    "civicrm_discount",
    "civicrm_domain",
    "civicrm_email",
    "civicrm_entity_batch",
    "civicrm_entity_file",
    "civicrm_entity_financial_account",
    "civicrm_entity_financial_trxn",
    "civicrm_entity_tag",
    "civicrm_event",
    "civicrm_extension",
    "civicrm_file",
    "civicrm_financial_account",
    "civicrm_financial_item",
    "civicrm_financial_trxn",
    "civicrm_financial_type",
    "civicrm_group",
    "civicrm_group_contact",
    "civicrm_group_contact_cache",
    "civicrm_group_nesting",
    "civicrm_group_organization",
    "civicrm_iats_faps_journal",
    "civicrm_iats_journal",
    "civicrm_iats_request_log",
    "civicrm_iats_response_log",
    "civicrm_iats_verify",
    "civicrm_im",
    "civicrm_install_canary",
    "civicrm_job",
    "civicrm_job_log",
    "civicrm_line_item",
    "civicrm_loc_block",
    "civicrm_location_type",
    "civicrm_log",
    "civicrm_mail_settings",
    "civicrm_mailing",
    "civicrm_mailing_abtest",
    "civicrm_mailing_archive_stat",
    "civicrm_mailing_bounce_pattern",
    "civicrm_mailing_bounce_type",
    "civicrm_mailing_component",
    "civicrm_mailing_event_bounce",
    "civicrm_mailing_event_confirm",
    "civicrm_mailing_event_delivered",
    "civicrm_mailing_event_forward",
    "civicrm_mailing_event_opened",
    "civicrm_mailing_event_queue",
    "civicrm_mailing_event_reply",
    "civicrm_mailing_event_subscribe",
    "civicrm_mailing_event_trackable_url_open",
    "civicrm_mailing_event_unsubscribe",
    "civicrm_mailing_group",
    "civicrm_mailing_job",
    "civicrm_mailing_recipients",
    "civicrm_mailing_spool",
    "civicrm_mailing_trackable_url",
    "civicrm_managed",
    "civicrm_mapping",
    "civicrm_mapping_field",
    "civicrm_membership",
    "civicrm_membership_block",
    "civicrm_membership_log",
    "civicrm_membership_payment",
    "civicrm_membership_status",
    "civicrm_membership_type",
    "civicrm_menu",
    "civicrm_msg_template",
    "civicrm_navigation",
    "civicrm_note",
    "civicrm_openid",
    "civicrm_option_group",
    "civicrm_option_value",
    "civicrm_participant",
    "civicrm_participant_payment",
    "civicrm_participant_status_type",
    "civicrm_payment_processor",
    "civicrm_payment_processor_type",
    "civicrm_payment_token",
    "civicrm_pcp",
    "civicrm_pcp_block",
    "civicrm_phone",
    "civicrm_pledge",
    "civicrm_pledge_block",
    "civicrm_pledge_payment",
    "civicrm_preferences_date",
    "civicrm_premiums",
    "civicrm_premiums_product",
    "civicrm_prevnext_cache",
    "civicrm_price_field",
    "civicrm_price_field_value",
    "civicrm_price_set",
    "civicrm_price_set_entity",
    "civicrm_print_label",
    "civicrm_product",
    "civicrm_queue",
    "civicrm_queue_item",
    "civicrm_recurring_entity",
    "civicrm_relationship",
    "civicrm_relationship_cache",
    "civicrm_relationship_type",
    "civicrm_report_instance",
    "civicrm_saved_search",
    "civicrm_search_display",
    "civicrm_search_segment",
    "civicrm_setting",
    "civicrm_site_token",
    "civicrm_sms_provider",
    "civicrm_sqltasks",
    "civicrm_sqltasks_action_template",
    "civicrm_sqltasks_template",
    "civicrm_state_province",
    "civicrm_status_pref",
    "civicrm_subscription_history",
    "civicrm_survey",
    "civicrm_system_log",
    "civicrm_tag",
    "civicrm_tell_friend",
    "civicrm_timezone",
    "civicrm_translation",
    "civicrm_uf_field",
    "civicrm_uf_group",
    "civicrm_uf_join",
    "civicrm_uf_match",
    "civicrm_user_job",
    "civicrm_value_accessibility_31",
    "civicrm_value_activity_source",
    "civicrm_value_additional_info_21",
    "civicrm_value_days_33",
    "civicrm_value_deduping_stri_29",
    "civicrm_value_dietary_prefe_30",
    "civicrm_value_donation_medi_26",
    "civicrm_value_donation_medi_27",
    "civicrm_value_end_of_year_s_35",
    "civicrm_value_foreign_keys_18",
    "civicrm_value_gpc_donations_19",
    "civicrm_value_involvement_10",
    "civicrm_value_personalization_14",
    "civicrm_value_phone_preferences_1",
    "civicrm_value_recurring_ux_36",
    "civicrm_value_reporting_4",
    "civicrm_value_representation_order_17",
    "civicrm_value_riding_info",
    "civicrm_value_status_3",
    "civicrm_value_summary_field_34",
    "civicrm_value_young_greens_20",
    "civicrm_value_zoom_link_28",
    "civicrm_website",
    "civicrm_word_replacement",
    "civicrm_worldregion",
    "civirule_action",
    "civirule_condition",
    "civirule_rule",
    "civirule_rule_action",
    "civirule_rule_action_backup",
    "civirule_rule_condition",
    "civirule_rule_log",
    "civirule_rule_tag",
    "civirule_trigger",
    "postal_codes"
  ]

  # Limit to 5 tables per transfer config. We've had problems doing many tables at once.
  transfer_batch_size = 5 
  civicrm_grouped_batches = {
    for batch_key in distinct([for idx, _ in local.civicrm_tables : format("batch_%03d", floor(idx / local.transfer_batch_size))]) :
    batch_key => [
      for idx, table in local.civicrm_tables :
      table
      # Include a table in this batch's list if its calculated batch key matches the current `batch_key`.
      if format("batch_%03d", floor(idx / local.transfer_batch_size)) == batch_key
    ]
  }
}

resource "google_bigquery_dataset" "civicrm_tables" {
  dataset_id    = "civicrm_tables"
  friendly_name = "CiviCRM Tables"
  location      = local.region
}

resource "google_bigquery_data_transfer_config" "civicrm_table_transfer_configs" {
  # One transfer config for each batch.
  for_each = local.civicrm_grouped_batches

  lifecycle {
    ignore_changes = [id, name] # GCP generates these after it's created
  }

  display_name   = "MySQL civicrm ${each.key}" # e.g., "MySQL civicrm batch_000"
  location       = local.region
  data_source_id = "mysql"

  # The schedule is based on the index of the batch.
  # We extract the batch number from the key and use it for scheduling.
  # Each batch runs one minute apart.
  # TODO: I wasn't able to make temporary variables here. There's duplicate logic below.
  # Can a var of some type be used to DRY it?
  schedule = format("every day %02d:%02d",
    floor(tonumber(trimprefix(try(regex("batch_(\\d+)", each.key)[0], "0"), "0")) / 60), # Calculate hour
    tonumber(trimprefix(try(regex("batch_(\\d+)", each.key)[0], "0"), "0")) % 60         # Calculate minute
  )
  
  destination_dataset_id = google_bigquery_dataset.civicrm_tables.dataset_id

  params = {
    "connector.database"                = "civicrm"
    "connector.endpoint.host"           = var.mysql_host
    "connector.endpoint.port"           = "3306"
    "connector.authentication.username" = var.mysql_username
    "connector.authentication.password" = var.mysql_password
    "connector.encryptionMode"          = "REQUIRE"
    # Join the list of tables in the batch with "civicrm/" prefix. The provider needs
    # this param to be a JSON array of strings, so we use jsonencode.
    "assets" = jsonencode([for table in each.value : "civicrm/${table}"])
  }
}
