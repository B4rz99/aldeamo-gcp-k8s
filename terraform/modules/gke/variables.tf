variable "region" {
  description = "The GCP region to deploy resources in"
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