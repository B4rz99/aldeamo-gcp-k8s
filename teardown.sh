#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$PROJECT_ROOT/terraform"
SSH_DIR="$PROJECT_ROOT/.ssh"
ANSIBLE_HOSTS="$PROJECT_ROOT/ansible/hosts"

echo "Starting full safe teardown..."

# Step 0: Capture outputs before infrastructure is destroyed
CLUSTER_NAME=$(terraform -chdir="$TF_DIR" output -raw cluster_name || echo "")
CLUSTER_LOCATION=$(terraform -chdir="$TF_DIR" output -raw location || echo "")

# Step 1: Delete GKE workloads and cluster
if [[ -n "$CLUSTER_NAME" && -n "$CLUSTER_LOCATION" ]]; then
  echo "Connecting to GKE cluster..."
  gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$CLUSTER_LOCATION" || true

  echo "Deleting Kubernetes workloads..."
  kubectl delete -f "$PROJECT_ROOT/k8s" --ignore-not-found || true

  echo "Deleting GKE cluster..."
  gcloud container clusters delete "$CLUSTER_NAME" --region "$CLUSTER_LOCATION" --quiet || true
else
  echo "GKE cluster not found or already deleted."
fi

# Step 2: Destroy the compute instance to unblock subnet deletion
echo "Destroying Compute Engine instance..."
terraform -chdir="$TF_DIR" destroy -target=module.compute -auto-approve || true

# Step 3: Destroy firewall rules via Terraform
echo "Destroying firewall rules via Terraform..."
terraform -chdir="$TF_DIR" destroy \
  -target=module.network.google_compute_firewall.allow-http \
  -target=module.network.google_compute_firewall.allow-ssh \
  -auto-approve || true

# Step 4: Force delete any lingering NEGs
echo "Force-deleting any remaining Network Endpoint Groups..."

gcloud compute network-endpoint-groups list \
  --filter="network:nginx-vpc" \
  --format="value(name, zone)" | while read -r neg zone_url; do
  zone=$(basename "$zone_url")
  echo "Deleting NEG: $neg in zone $zone..."
  gcloud compute network-endpoint-groups delete "$neg" --zone="$zone" --quiet || echo "Could not delete $neg"
done

# Step 5: Destroy remaining Terraform-managed infrastructure
echo "Destroying all remaining infrastructure..."
terraform -chdir="$TF_DIR" destroy -auto-approve || true

# Step 6: Clean up local artifacts
echo "Cleaning up local artifacts..."
rm -rf "$SSH_DIR"
rm -f "$ANSIBLE_HOSTS"

echo "Teardown complete."