resource "digitalocean_spaces_bucket" "drupal" {
  name   = "drupal%{if var.environment == "stage"}-stage%{endif}"
  region = "nyc3"
}
