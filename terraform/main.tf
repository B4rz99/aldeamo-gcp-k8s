provider "google" {
  project = var.project_id
  region  = var.region
}

module "network" {
  source = "./modules/network"
  region = var.region
}