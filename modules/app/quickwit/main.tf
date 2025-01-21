resource "aws_s3_bucket" "quickwit" {
  bucket_prefix = local.name
  tags = {
    Name = local.name
  }
}
