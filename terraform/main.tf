terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = "practiceproject-495412"
  region  = "asia-south1"
}

# New project network layout
resource "google_compute_network" "main_vpc" {
  name                    = "new-project-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "new-project-subnet"
  region        = "asia-south1"
  network       = google_compute_network.main_vpc.id
  ip_cidr_range = "10.0.0.0/24"
}

resource "google_artifact_registry_repository" "backend_repo" {
  location      = "asia-south1"
  repository_id = "new-project-repo"
  description   = "Docker registry for the new GitHub Actions pipeline"
  format        = "DOCKER"
}