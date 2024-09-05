resource "digitalocean_spaces_bucket" "drupal" {
  name   = "drupal"
  region = "nyc3"
}

resource "digitalocean_spaces_bucket_policy" "example_policy" {
  bucket = digitalocean_spaces_bucket.drupal.name
  region = digitalocean_spaces_bucket.drupal.region
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "PrivateAccess",
        "Effect" : "Deny",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${digitalocean_spaces_bucket.drupal.name}/private/*"
      }
    ]
  })
}
