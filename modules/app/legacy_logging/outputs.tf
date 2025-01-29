output "access_key" {
  value = {
    "aws_access_key_id" : aws_iam_access_key.digital_ocean_monitoring.id
    "aws_secret_access_key" : aws_iam_access_key.digital_ocean_monitoring.secret
  }
}
