# The GCP zone where resources will be deployed.
variable "zone" {
  description = "The GCP zone to deploy zonal resources in"
  type        = string
}

# The name of the VPC network to attach the proxy instance to.
variable "network" {
  description = "The self_link or name of the VPC network"
  type        = string
}

# The name of the subnet within the specified VPC network.
variable "subnet" {
  description = "The self_link or name of the subnet"
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