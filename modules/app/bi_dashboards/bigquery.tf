provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

locals {
  # We need a transfer config to run for every table, but we've had problems in the past trying it
  # two ways:
  #
  # 1) One transfer config with all tables in it
  # 2) One transfer config per table, each scheduled at the same time
  #
  # In both cases, the transfer configs will fail with a generic MySQL error and we think it's
  # because GCP is trying to transfer too much at once.
  #
  # So this is an approach that seems to work around these issues well so far. We group the tables
  # into batches of 5 and use a transfer config for each batch. Each transfer config has a schedule
  # that causes it to run one minute after the previous one. This spaces things out nicely so that
  # no runs fail but also gets through all the tables in a reasonable amount of time. We can tune
  # this more later if we want to.
  #
  # The tables in this map were obtained by querying MySQL for a list of all CiviCRM tables
  # Sept 29th 2025. We must repeat that process and update the code here if that ever changes.
  #
  # See `resource` below to see how this ends up being used to ultimately
  # cause a resource to be generated for each batch.
  civicrm_batches = {
    # The key is the batch number. It's used in `resource` below for the transfer config name.
    1 = {
      schedule = "every day 00:00"
      tables = [
        "cdntaxreceipts_log",
        "cdntaxreceipts_log_contributions",
        "civicrm_acl",
        "civicrm_acl_cache",
        "civicrm_acl_contact_cache",
      ]
    }
    2 = {
      schedule = "every day 00:01"
      tables = [
        "civicrm_acl_entity_role",
        "civicrm_action_log",
        "civicrm_action_schedule",
        "civicrm_activity",
        "civicrm_activity_contact",
      ]
    }
    3 = {
      schedule = "every day 00:02"
      tables = [
        "civicrm_address",
        "civicrm_address_format",
        "civicrm_afform_submission",
        "civicrm_batch",
        "civicrm_cache",
      ]
    }
    4 = {
      schedule = "every day 00:03"
      tables = [
        "civicrm_campaign",
        "civicrm_campaign_group",
        "civicrm_case",
        "civicrm_case_activity",
        "civicrm_case_contact",
      ]
    }
    5 = {
      schedule = "every day 00:04"
      tables = [
        "civicrm_case_type",
        "civicrm_cdntaxreceipts",
        "civicrm_component",
        "civicrm_contact",
        "civicrm_contact_type",
      ]
    }
    6 = {
      schedule = "every day 00:05"
      tables = [
        "civicrm_contribution",
        "civicrm_contribution_page",
        "civicrm_contribution_product",
        "civicrm_contribution_recur",
        "civicrm_contribution_soft",
      ]
    }
    7 = {
      schedule = "every day 00:06"
      tables = [
        "civicrm_contribution_widget",
        "civicrm_country",
        "civicrm_county",
        "civicrm_currency",
        "civicrm_custom_field",
      ]
    }
    8 = {
      schedule = "every day 00:07"
      tables = [
        "civicrm_custom_group",
        "civicrm_cxn",
        "civicrm_dashboard",
        "civicrm_dashboard_contact",
        "civicrm_dedupe_exception",
      ]
    }
    9 = {
      schedule = "every day 00:08"
      tables = [
        "civicrm_dedupe_rule",
        "civicrm_dedupe_rule_group",
        "civicrm_discount",
        "civicrm_domain",
        "civicrm_email",
      ]
    }
    10 = {
      schedule = "every day 00:09"
      tables = [
        "civicrm_entity_batch",
        "civicrm_entity_file",
        "civicrm_entity_financial_account",
        "civicrm_entity_financial_trxn",
        "civicrm_entity_tag",
      ]
    }
    11 = {
      schedule = "every day 00:10"
      tables = [
        "civicrm_event",
        "civicrm_extension",
        "civicrm_file",
        "civicrm_financial_account",
        "civicrm_financial_item",
      ]
    }
    12 = {
      schedule = "every day 00:11"
      tables = [
        "civicrm_financial_trxn",
        "civicrm_financial_type",
        "civicrm_group",
        "civicrm_group_contact",
        "civicrm_group_contact_cache",
      ]
    }
    13 = {
      schedule = "every day 00:12"
      tables = [
        "civicrm_group_nesting",
        "civicrm_group_organization",
        "civicrm_iats_faps_journal",
        "civicrm_iats_journal",
        "civicrm_iats_request_log",
      ]
    }
    14 = {
      schedule = "every day 00:13"
      tables = [
        "civicrm_iats_response_log",
        "civicrm_iats_verify",
        "civicrm_im",
        "civicrm_install_canary",
        "civicrm_job",
      ]
    }
    15 = {
      schedule = "every day 00:14"
      tables = [
        "civicrm_job_log",
        "civicrm_line_item",
        "civicrm_loc_block",
        "civicrm_location_type",
        "civicrm_log",
      ]
    }
    16 = {
      schedule = "every day 00:15"
      tables = [
        "civicrm_mail_settings",
        "civicrm_mailing",
        "civicrm_mailing_abtest",
        "civicrm_mailing_archive_stat",
        "civicrm_mailing_bounce_pattern",
      ]
    }
    17 = {
      schedule = "every day 00:16"
      tables = [
        "civicrm_mailing_bounce_type",
        "civicrm_mailing_component",
        "civicrm_mailing_event_bounce",
        "civicrm_mailing_event_confirm",
        "civicrm_mailing_event_delivered",
      ]
    }
    18 = {
      schedule = "every day 00:17"
      tables = [
        "civicrm_mailing_event_forward",
        "civicrm_mailing_event_opened",
        "civicrm_mailing_event_queue",
        "civicrm_mailing_event_reply",
        "civicrm_mailing_event_subscribe",
      ]
    }
    19 = {
      schedule = "every day 00:18"
      tables = [
        "civicrm_mailing_event_trackable_url_open",
        "civicrm_mailing_event_unsubscribe",
        "civicrm_mailing_group",
        "civicrm_mailing_job",
        "civicrm_mailing_recipients",
      ]
    }
    20 = {
      schedule = "every day 00:19"
      tables = [
        "civicrm_mailing_spool",
        "civicrm_mailing_trackable_url",
        "civicrm_managed",
        "civicrm_mapping",
        "civicrm_mapping_field",
      ]
    }
    21 = {
      schedule = "every day 00:20"
      tables = [
        "civicrm_membership",
        "civicrm_membership_block",
        "civicrm_membership_log",
        "civicrm_membership_payment",
        "civicrm_membership_status",
      ]
    }
    22 = {
      schedule = "every day 00:21"
      tables = [
        "civicrm_membership_type",
        "civicrm_menu",
        "civicrm_msg_template",
        "civicrm_navigation",
        "civicrm_note",
      ]
    }
    23 = {
      schedule = "every day 00:22"
      tables = [
        "civicrm_openid",
        "civicrm_option_group",
        "civicrm_option_value",
        "civicrm_participant",
        "civicrm_participant_payment",
      ]
    }
    24 = {
      schedule = "every day 00:23"
      tables = [
        "civicrm_participant_status_type",
        "civicrm_payment_processor",
        "civicrm_payment_processor_type",
        "civicrm_payment_token",
        "civicrm_pcp",
      ]
    }
    25 = {
      schedule = "every day 00:24"
      tables = [
        "civicrm_pcp_block",
        "civicrm_phone",
        "civicrm_pledge",
        "civicrm_pledge_block",
        "civicrm_pledge_payment",
      ]
    }
    26 = {
      schedule = "every day 00:25"
      tables = [
        "civicrm_preferences_date",
        "civicrm_premiums",
        "civicrm_premiums_product",
        "civicrm_prevnext_cache",
        "civicrm_price_field",
      ]
    }
    27 = {
      schedule = "every day 00:26"
      tables = [
        "civicrm_price_field_value",
        "civicrm_price_set",
        "civicrm_price_set_entity",
        "civicrm_print_label",
        "civicrm_product",
      ]
    }
    28 = {
      schedule = "every day 00:27"
      tables = [
        "civicrm_queue",
        "civicrm_queue_item",
        "civicrm_recurring_entity",
        "civicrm_relationship",
        "civicrm_relationship_cache",
      ]
    }
    29 = {
      schedule = "every day 00:28"
      tables = [
        "civicrm_relationship_type",
        "civicrm_report_instance",
        "civicrm_saved_search",
        "civicrm_search_display",
        "civicrm_search_segment",
      ]
    }
    30 = {
      schedule = "every day 00:29"
      tables = [
        "civicrm_setting",
        "civicrm_site_token",
        "civicrm_sms_provider",
        "civicrm_sqltasks",
        "civicrm_sqltasks_action_template",
      ]
    }
    31 = {
      schedule = "every day 00:30"
      tables = [
        "civicrm_sqltasks_template",
        "civicrm_state_province",
        "civicrm_status_pref",
        "civicrm_subscription_history",
        "civicrm_survey",
      ]
    }
    32 = {
      schedule = "every day 00:31"
      tables = [
        "civicrm_system_log",
        "civicrm_tag",
        "civicrm_tell_friend",
        "civicrm_timezone",
        "civicrm_translation",
      ]
    }
    33 = {
      schedule = "every day 00:32"
      tables = [
        "civicrm_uf_field",
        "civicrm_uf_group",
        "civicrm_uf_join",
        "civicrm_uf_match",
        "civicrm_user_job",
      ]
    }
    34 = {
      schedule = "every day 00:33"
      tables = [
        "civicrm_value_accessibility_31",
        "civicrm_value_activity_source",
        "civicrm_value_additional_info_21",
        "civicrm_value_days_33",
        "civicrm_value_deduping_stri_29",
      ]
    }
    35 = {
      schedule = "every day 00:34"
      tables = [
        "civicrm_value_dietary_prefe_30",
        "civicrm_value_donation_medi_26",
        "civicrm_value_donation_medi_27",
        "civicrm_value_end_of_year_s_35",
        "civicrm_value_foreign_keys_18",
      ]
    }
    36 = {
      schedule = "every day 00:35"
      tables = [
        "civicrm_value_gpc_donations_19",
        "civicrm_value_involvement_10",
        "civicrm_value_personalization_14",
        "civicrm_value_phone_preferences_1",
        "civicrm_value_recurring_ux_36",
      ]
    }
    37 = {
      schedule = "every day 00:36"
      tables = [
        "civicrm_value_reporting_4",
        "civicrm_value_representation_order_17",
        "civicrm_value_riding_info",
        "civicrm_value_status_3",
        "civicrm_value_summary_field_34",
      ]
    }
    38 = {
      schedule = "every day 00:37"
      tables = [
        "civicrm_value_young_greens_20",
        "civicrm_value_zoom_link_28",
        "civicrm_website",
        "civicrm_word_replacement",
        "civicrm_worldregion",
      ]
    }
    39 = {
      schedule = "every day 00:38"
      tables = [
        "civirule_action",
        "civirule_condition",
        "civirule_rule",
        "civirule_rule_action",
        "civirule_rule_action_backup",
      ]
    }
    40 = {
      schedule = "every day 00:39"
      tables = [
        "civirule_rule_condition",
        "civirule_rule_log",
        "civirule_rule_tag",
        "civirule_trigger",
        "postal_codes"
      ]
    }
  }
}

# The BigQuery dataset that contains each table.
resource "google_bigquery_dataset" "civicrm_tables" {
  dataset_id    = "civicrm_tables"
  friendly_name = "CiviCRM Tables"
  location      = var.gcp_region
}

# A BigQuery Data Transfer Service transfer config.
resource "google_bigquery_data_transfer_config" "civicrm_table_transfer_configs" {
  # `for_each` creates a transfer config for each batch of tables.
  for_each = local.civicrm_batches

  destination_dataset_id = google_bigquery_dataset.civicrm_tables.dataset_id

  lifecycle {
    ignore_changes = [
      # GCP uses the raw password while it's created but stores it hashed.
      params["connector.authentication.password"]
    ]
  }

  # Use the key of the map in the display name so that each transfer config has a unique name.
  display_name   = "MySQL CiviCRM tables (batch ${each.key}/${length(local.civicrm_batches)})"
  location       = var.gcp_region
  data_source_id = "mysql"
  schedule       = each.value.schedule

  params = {
    "connector.database"                = "civicrm"
    "connector.endpoint.host"           = var.mysql_host
    "connector.endpoint.port"           = "3306"
    "connector.authentication.username" = var.mysql_username
    "connector.authentication.password" = var.mysql_password
    "connector.encryptionMode"          = "REQUIRE"
    # `jsonencode` converts the data in the Terraform code to the JSON string array that GCP needs.
    "assets" = jsonencode([
      # `for` maps each table name to the complete string that GCP needs for each table.
      for table in each.value.tables : "civicrm/${table}"
    ])
  }
}
