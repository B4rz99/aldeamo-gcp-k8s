output "proxy_ip" {
  value = module.compute.public_ip
}

# output "ingress_ip" {
#   value = module.gke.ingress_ip
# }

output "cluster_name" {
  value = module.gke.cluster_name
}

output "location" {
  value = module.gke.location
}