# The GCP project ID where all infrastructure will be deployed.
variable "project_id" {
  description = "The GCP project ID to deploy resources into"
  type        = string
}

# The region to deploy regional GCP resources like the VPC, subnets, and GKE cluster.
variable "region" {
  description = "The GCP region to deploy resources in"
  type        = string
}

# The GCP zone where resources will be deployed.
 variable "zone" {
   description = "The GCP zone to deploy zonal resources in"
   type        = string
 }
 
 # The username used to SSH into the proxy VM instance.
 variable "ssh_user" {
   description = "The SSH username for connecting to the Compute Engine instance"
   type        = string
 }
 
 # The local filesystem path to the public SSH key.
# This key will be injected into the VM’s metadata for SSH access.
 variable "ssh_public_key_path" {
   description = "Path to the public SSH key for the proxy VM"
   type        = string
 }