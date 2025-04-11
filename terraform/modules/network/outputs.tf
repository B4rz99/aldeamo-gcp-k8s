# Outputs the ID of the custom VPC network.
# This value is used as an input in other modules or Terraform files that need to reference the VPC,
# such as the GKE cluster or proxy VM network interfaces.
output "vpc_id" {
  value = google_compute_network.vpc.id
}

# Outputs the ID of the custom subnet.
# Required by GKE and Compute Engine resources to correctly attach to the intended subnet.
output "subnet_id" {
  value = google_compute_subnetwork.subnet.id
}