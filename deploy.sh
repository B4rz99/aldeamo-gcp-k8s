#!/bin/bash

set -euo pipefail

# STEP 1: Set working paths and variables
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_DIR="$PROJECT_ROOT/.ssh"
KEY_PATH="$KEY_DIR/id_rsa"
PUB_KEY_PATH="${KEY_PATH}.pub"
SSH_USER="debian"
INGRESS_NAME="ingress"

# STEP 2: Generate fresh SSH key pair
echo "Step 2: Rotating SSH key..."
rm -f "$KEY_PATH" "$PUB_KEY_PATH"
mkdir -p "$KEY_DIR"
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "terraform@proxy" <<< y > /dev/null

# STEP 3: Apply infrastructure with Terraform
echo "Step 3: Running Terraform..."
terraform -chdir="$PROJECT_ROOT/terraform" init
terraform -chdir="$PROJECT_ROOT/terraform" apply \
  -var="ssh_user=$SSH_USER" \
  -var="ssh_public_key_path=$PUB_KEY_PATH" \
  -auto-approve

# STEP 4: Extract outputs (VM IP, Cluster info)
echo "Step 4: Getting public IPs from Terraform outputs..."
PROXY_IP=$(terraform -chdir="$PROJECT_ROOT/terraform" output -raw proxy_ip)
CLUSTER_NAME=$(terraform -chdir="$PROJECT_ROOT/terraform" output -raw cluster_name)
CLUSTER_LOCATION=$(terraform -chdir="$PROJECT_ROOT/terraform" output -raw location)

# STEP 5: Connect to the GKE cluster
echo "Step 5: Connecting to GKE Cluster..."
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$CLUSTER_LOCATION"

# STEP 6: Deploy Kubernetes manifests to the cluster
echo "Step 6: Deploying application to Kubernetes..."
kubectl apply -f "$PROJECT_ROOT/k8s"

# STEP 7: Wait for Ingress IP allocation
echo "Step 7: Waiting for external IP on ingress '$INGRESS_NAME'..."
while true; do
  INGRESS_IP=$(kubectl get ingress "$INGRESS_NAME" -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "")
  if [[ $INGRESS_IP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo -e "\nIngress is ready! IP: $INGRESS_IP"
    break
  else
    echo "$(date +%H:%M:%S) Still waiting for Ingress IP..."
    sleep 5
  fi
done

# STEP 8: Create dynamic Ansible inventory
echo "Step 8: Creating Ansible inventory..."
cd "$PROJECT_ROOT/ansible"
echo "[proxy]" > hosts
echo "$PROXY_IP ansible_user=$SSH_USER ansible_ssh_private_key_file=$KEY_PATH" >> hosts

# STEP 9: Wait for SSH on the VM
echo "Step 9: Waiting for VM SSH to become available..."
until ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" -q "$SSH_USER@$PROXY_IP" exit; do
  printf "."
  sleep 5
done
echo "SSH is now available!"

# STEP 10: Run Ansible playbook for NGINX configuration
echo "Step 10: Running Ansible playbook..."
ansible-playbook -i hosts nginx-proxy.yml \
  --extra-vars "domain=$INGRESS_IP ingress_ip=$INGRESS_IP" -vv

# STEP 11: Done!
echo "Step 11: 🎉 Deployment complete!"
echo "---------------------------------------------------"
echo "GKE Ingress is accessible at: http://$INGRESS_IP"
echo "Reverse Proxy (VM) is accessible at: http://$PROXY_IP"
echo "---------------------------------------------------"