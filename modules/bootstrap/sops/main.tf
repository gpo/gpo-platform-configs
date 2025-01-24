resource "aws_kms_key" "sops" {
  description = "This key is used in the https://github.com/gpo/gpo-platform-configs repo to manage secrets using https://github.com/getsops/sops"
}

resource "aws_kms_alias" "sops" {
  name          = "alias/sops-${var.environment}"
  target_key_id = aws_kms_key.sops.key_id
}
