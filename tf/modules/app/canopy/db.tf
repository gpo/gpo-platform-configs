locals {
  secret_id = "canopy-db"
}

resource "random_id" "canopy_name_suffix" {
  byte_length = 4
}

data "google_compute_network" "main" {
  name = var.vpc_network_name
}

resource "google_sql_database_instance" "canopy" {
  name             = "canopy-${random_id.canopy_name_suffix.hex}"
  database_version = "MYSQL_8_4"
  region           = var.region

  settings {
    ip_configuration {
      ipv4_enabled    = false
      private_network = data.google_compute_network.main.id
    }

    edition = var.database_edition

    tier = var.database_tier

    location_preference {
      zone = var.zone
    }
  }
}

resource "google_sql_database" "canopy" {
  name      = "canopy"
  instance  = google_sql_database_instance.canopy.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

resource "random_password" "canopy" {
  length  = 24
  special = false // wp-config can be grumpy about special chars
}

resource "google_sql_user" "canopy" {
  name     = "canopy"
  instance = google_sql_database_instance.canopy.name
  password = random_password.canopy.result
}

resource "google_secret_manager_secret" "canopy_db" {
  secret_id = local.secret_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "canopy_db" {
  secret = google_secret_manager_secret.canopy_db.id

  secret_data = jsonencode({
    DB_HOST     = google_sql_database_instance.canopy.private_ip_address
    DB_NAME     = google_sql_database.canopy.name
    DB_USER     = google_sql_user.canopy.name
    DB_PASSWORD = random_password.canopy.result
  })
}
