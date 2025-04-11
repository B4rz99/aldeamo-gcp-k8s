# Creates a GKE cluster.
resource "google_container_cluster" "nginx_cluster" {
    name     = "nginx-cluster"
    location = var.region
    remove_default_node_pool = true
    deletion_protection = false
    initial_node_count       = 1
    network    = var.network
    subnetwork = var.subnet
    ip_allocation_policy {}
    
    release_channel {
        channel = "STABLE"
    }
}

# Defines a custom node pool for the GKE cluster with preemptible VMs.
# Used to run your workloads (like NGINX pods) on cost-efficient compute.
resource "google_container_node_pool" "nginx_pool" {
    name       = "nginx-pool"
    location   = var.region
    cluster    = google_container_cluster.nginx_cluster.name
    node_count = 2
    node_config {
        preemptible  = true
        machine_type = "e2-medium"
        disk_size_gb = 50
        oauth_scopes = [
            "https://www.googleapis.com/auth/cloud-platform"
        ]
        labels = {
          env = "dev"
        }
        tags = ["nginx-node"]
    }
}