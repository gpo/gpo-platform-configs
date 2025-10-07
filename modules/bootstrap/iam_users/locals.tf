locals {
  grant_stage_access = lower(var.environment) == "stage"
}
