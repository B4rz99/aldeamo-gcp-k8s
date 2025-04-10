variable "zone" {
  description = "The GCP zone to deploy zonal resources in"
  type        = string
}
variable "network" {
 description = "The self_link or name of the VPC network"
 type        = string
}

variable "subnet" {
  description = "The self_link or name of the subnet"
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