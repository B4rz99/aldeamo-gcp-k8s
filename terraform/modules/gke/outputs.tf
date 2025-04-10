output "cluster_name" {
    value = google_container_cluster.nginx_cluster.name
}

output "location" {
    value = google_container_cluster.nginx_cluster.location
}