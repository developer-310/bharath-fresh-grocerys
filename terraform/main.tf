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

# VPC and Subnet
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

# PRIVATE SERVICE ACCESS (Required for Private GKE to talk to Cloud SQL)
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main_vpc.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main_vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_artifact_registry_repository" "backend_repo" {
  location      = "asia-south1"
  repository_id = "new-project-repo"
  format        = "DOCKER"
}