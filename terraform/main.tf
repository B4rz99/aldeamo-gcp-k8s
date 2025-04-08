provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source = "./modules/network"
  region = var.region
}

module "compute" {
  source = "./modules/compute"
  zone = var.zone
  network = module.network.vpc_id
  subnet = module.network.subnet_id
  ssh_user = var.ssh_user
  ssh_public_key_path = var.ssh_public_key_path
}