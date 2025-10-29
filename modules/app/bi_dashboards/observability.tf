locals {
  run_failure_metric_name = "transfer_config_job_run_failures2"
}

# Tracks transfer config run job failures by looking for the messages GCP logs
# when a run job fails. We assume any job failing is for the BI dashboards. We
# can fine tune this later if we want to.
resource "google_logging_metric" "logging_metric" {
  name   = local.run_failure_metric_name
  filter = "resource.type=\"bigquery_dts_config\" AND severity>=ERROR"
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
  description = "BI dashboard BQ DTS transfer config run job failures."
}

# Allows us to send emails to multiple GPO team members at the same time when a
# run job fails.
resource "google_monitoring_notification_channel" "gpo_email" {
  display_name = "Data monitoring email group"
  type         = "email"
  labels = {
    email_address = var.monitoring_data_email
  }
  force_delete = false
}

# Alerting policy that watches the log based metric (see
# google_monitoring_notification_channel above) and emails us using the email
# notification channel (see google_monitoring_notification_channel above) when
# at least 1 job has failed.
resource "google_monitoring_alert_policy" "email_when_run_job_fails" {
  combiner              = "OR"
  display_name          = "Nightly sync from database to BigQuery for BI dashboards failed"
  enabled               = true
  notification_channels = [google_monitoring_notification_channel.gpo_email.id]
  project               = var.gcp_project
  severity              = "CRITICAL"
  conditions {
    display_name = "transfer_config_job_run_failures above 0 in past 15 minutes"
    condition_threshold {
      comparison      = "COMPARISON_GT"
      duration        = "0s"
      filter          = "resource.type = \"bigquery_dts_config\" AND metric.type = \"logging.googleapis.com/user/transfer_config_job_run_failures\""
      threshold_value = 0
      aggregations {
        alignment_period     = "60s"
        cross_series_reducer = "REDUCE_COUNT"
        per_series_aligner   = "ALIGN_COUNT"
      }
      trigger {
        count = 1
      }
    }
  }
  documentation {
    content   = "We need to make sure all of our BigQuery Data Transfer Service transfer configs are working. Check the list of transfer configs under the BigQuery part of the BigQuery console. Look at the runs for a transfer config by clicking on it. The most recent run is displayed at the top of that list. Determine which transfer config had a failed run and why the run failed. If you can solve the issue yourself, do so and then notify the team on Slack what you did. If you can't solve the issue yourself, notify the team on Slack and work with them to solve the issue. Use your best judgement for whether to ping them right now (e.g. it might be overnight and the job might not be crucial to fix overnight)."
    mime_type = "text/markdown"
    subject   = "Recent nightly sync for BI dashboards failed"
  }
}
