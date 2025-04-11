# Specifies the GCP region where resources will be deployed.
variable "region" {
  description = "The GCP region to deploy resources in"
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