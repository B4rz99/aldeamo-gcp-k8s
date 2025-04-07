variable "project_id" {
  description = "The GCP project ID to deploy resources into"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources in"
  type        = string
}

variable "zone" {
  description = "The GCP zone to deploy zonal resources in"
  type        = string
}

variable "ssh_user" {
  description = "The SSH username for connecting to the Compute Engine instance"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key for the proxy VM"
  type        = string
}

variable "domain" {
  description = "The domain name (e.g. www.example.com) for the HTTPS proxy"
  type        = string
}