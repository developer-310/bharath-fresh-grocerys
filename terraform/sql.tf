resource "google_sql_database_instance" "master" {
  name             = "bharath-fresh-db-instance"
  database_version = "MYSQL_8_0"
  region           = "asia-south1"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false # Keep DB private
      private_network = google_compute_network.main_vpc.id
    }
  }
}

resource "google_sql_database" "database" {
  name     = "bharath_fresh_db"
  instance = google_sql_database_instance.master.name
}

resource "google_sql_user" "users" {
  name     = "root"
  instance = google_sql_database_instance.master.name
  password = "Prudhviraj@310" # SECURITY NOTE: Use Vault or Secret Manager in real prod
}