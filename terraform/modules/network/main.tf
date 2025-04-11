# Creates a custom VPC named 'nginx-vpc'.
# Disables automatic subnet creation so we can explicitly define subnets for better control.
resource "google_compute_network" "vpc" {
    name                    = "nginx-vpc"
    auto_create_subnetworks = false
}

# Defines a custom subnet within the 'nginx-vpc' network.
# Allocates a specific CIDR block for internal traffic between your GKE cluster and proxy VM.
resource "google_compute_subnetwork" "subnet" {
    name          = "nginx-subnet"
    ip_cidr_range = "10.10.0.0/24"
    region        = var.region
    network       = google_compute_network.vpc.id
}

# Firewall rule to allow SSH access (port 22) from any IP address to instances with the "proxy" tag.
# Required to allow Ansible or manual SSH into the reverse proxy VM.
resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # Open to the world (could restrict to a specific IP for better security)
  target_tags   = ["proxy"]
}

# Firewall rule to allow HTTP (port 80) traffic to the proxy instance.
resource "google_compute_firewall" "allow-http" {
  name    = "allow-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["proxy"]
}

# Firewall rule to allow HTTPS (port 443) traffic to the proxy instance.
# This is essential for serving traffic securely with TLS termination in NGINX.
resource "google_compute_firewall" "allow-https" {
  name    = "allow-https"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["proxy"]
}