resource "google_container_cluster" "primary" {
  name     = "new-project-cluster"
  location = "asia-south1"
  
  # Ensure networking is set up before GKE creation
  depends_on = [google_service_networking_connection.private_vpc_connection]

  network    = google_compute_network.main_vpc.id
  subnetwork = google_compute_subnetwork.private_subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/14"
    services_ipv4_cidr_block = "/20"
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "new-project-node-pool"
  location   = "asia-south1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}