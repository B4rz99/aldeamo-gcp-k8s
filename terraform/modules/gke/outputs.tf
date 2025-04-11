# Outputs the name of the GKE cluster.
# This value is used in the deploy.sh script (Step 4) to configure kubectl access.
output "cluster_name" {
    value = google_container_cluster.nginx_cluster.name
}

# Outputs the location (region or zone) of the GKE cluster.
# This is required alongside the cluster name when authenticating kubectl via gcloud.
output "location" {
    value = google_container_cluster.nginx_cluster.location
}