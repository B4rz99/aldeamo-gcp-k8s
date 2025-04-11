terraform {
  backend "gcs" {
    bucket = "aldeamo-terraform"
    prefix = "terraform/state"
  }
}

# Configures the GCP provider with the specified project and region.
provider "google" {
  project = var.project_id
  region  = var.region
}

# Provisions the base VPC and subnet for the infrastructure.
module "network" {
  source = "./modules/network"
  region = var.region
}

# Creates a Compute Engine instance (reverse proxy VM).
module "compute" {
  source = "./modules/compute"
  zone = var.zone
  network = module.network.vpc_id
  subnet = module.network.subnet_id
  ssh_user = var.ssh_user
  ssh_public_key_path = var.ssh_public_key_path
  # Ensures network resources are created before the compute instance is provisioned
  depends_on = [module.network]
}


# Provisions a GKE cluster and node pool
module "gke" {
  source = "./modules/gke"
  region = var.region
  network = module.network.vpc_id
  subnet = module.network.subnet_id
}