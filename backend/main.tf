terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "practiceproject-495412" # Your verified GCP Project ID
  region  = "us-east1"
}

# 1. Enable Required APIs inside your project
resource "google_project_service" "run_api" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "sql_api" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

# 2. Create the Managed Google Cloud SQL MySQL Instance Engine
resource "google_sql_database_instance" "mysql_instance" {
  name             = "bharath-grocery-db-instance"
  region           = "us-east1"
  database_version = "MYSQL_8_0"
  
  depends_on = [google_project_service.sql_api]

  settings {
    tier = "db-f1-micro" # Lightweight development tier to optimize cloud costs
    ip_configuration {
      ipv4_enabled = true
      
      # Allows your local machine (MySQL Workbench) and cloud environment to connect
      authorized_networks {
        name  = "public-access"
        value = "0.0.0.0/0"
      }
    }
  }
  deletion_protection = false # Set to false so you can cleanly destroy resources if resetting
}

# 3. Create the Database Schema Space inside the engine
resource "google_sql_database" "grocery_db" {
  name     = "bharath_fresh_grocerys"
  instance = google_sql_database_instance.mysql_instance.name
}

# 4. Create the Database Administrator User Account
resource "google_sql_user" "db_user" {
  name     = "bharath_admin"
  instance = google_sql_database_instance.mysql_instance.name
  password = "SecureGroceryPassword2026!" # Your database master password
}

# 5. Deploy your backend container to Google Cloud Run with Database Links
resource "google_cloud_run_v2_service" "backend" {
  name     = "bharath-fresh-backend"
  location = "us-east1"
  ingress  = "INGRESS_TRAFFIC_ALL" # Allows web requests from the internet

  depends_on = [google_project_service.run_api, google_sql_database_instance.mysql_instance]

  template {
    containers {
      # Points to the Docker image path in your Artifact Registry repository
      image = "us-east1-docker.pkg.dev/practiceproject-495412/bharath-backend-repo/backend:latest"
      
      ports {
        container_port = 8080 # Matches our Dockerfile EXPOSE port
      }

      env {
        name  = "NODE_ENV"
        value = "production"
      }

      # --- 🔗 AUTOMATED DATABASE ENVIRONMENT VARIABLES ---
      env {
        name  = "DB_HOST"
        value = google_sql_database_instance.mysql_instance.public_ip_address
      }
      env {
        name  = "DB_USER"
        value = google_sql_user.db_user.name
      }
      env {
        name  = "DB_PASSWORD"
        value = google_sql_user.db_user.password
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.grocery_db.name
      }
      
    }
  }
}

# 6. Make the backend publicly accessible over the internet securely
resource "google_cloud_run_v2_service_iam_member" "public_access" {
  name     = google_cloud_run_v2_service.backend.name
  location = google_cloud_run_v2_service.backend.location
  role     = "roles/run.invoker" # Correct target role for public invocation in Cloud Run v2
  member   = "allUsers"
}

# 7. Print Infrastructure Outputs when deployment finishes
output "backend_url" {
  value       = google_cloud_run_v2_service.backend.uri
  description = "The public live web link for your Express API backend"
}

output "database_public_ip" {
  value       = google_sql_database_instance.mysql_instance.public_ip_address
  description = "The public static IP address to put into MySQL Workbench"
}