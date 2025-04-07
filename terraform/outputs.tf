output "proxy_ip" {
  value = module.compute.public_ip
}

output "ingress_ip" {
  value = module.gke.ingress_ip
}
