# Output the external (public) IP address of the proxy VM
# This is used to connect via SSH or to route external traffic through the reverse proxy
output "public_ip" {
  value = google_compute_instance.proxy_instance.network_interface[0].access_config[0].nat_ip
}