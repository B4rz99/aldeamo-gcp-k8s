resource "google_compute_network" "vpc" {
    name                    = "nginx-vpc"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "name" {
    name          = "nginx-subnet"
    ip_cidr_range = "10.10.0.0/24"
    region        = var.region
    network       = google_compute_network.vpc.id
}

output "vpc_id" {
  value = google_compute_network.vpc.id
}

output "subnet_id" {
  value = google_compute_subnetwork.name.id
}