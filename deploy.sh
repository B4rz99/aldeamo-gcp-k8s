#!/bin/bash

set -euo pipefail

# Clean up old SSH key
rm -f "$KEY_DIR/id_rsa" "$KEY_DIR/id_rsa.pub"

# Set working paths
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_DIR="$PROJECT_ROOT/.ssh"
KEY_PATH="$KEY_DIR/id_rsa"
PUB_KEY_PATH="${KEY_PATH}.pub"
SSH_USER="debian"

# Rotate SSH key
echo "Rotating SSH key..."
mkdir -p "$KEY_DIR"
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "terraform@proxy" <<< y > /dev/null

# Run Terraform
echo "Running Terraform..."
terraform -chdir="$PROJECT_ROOT/terraform" init
terraform -chdir="$PROJECT_ROOT/terraform" apply \
  -var="ssh_user=$SSH_USER" \
  -var="ssh_public_key_path=$PUB_KEY_PATH" \
  -auto-approve

# Get VM public IP from Terraform output
echo "Getting public IP from Terraform..."
PROXY_IP=$(terraform -chdir="$PROJECT_ROOT/terraform" output -raw proxy_ip)

# Create Ansible inventory dynamically
echo "Creating Ansible inventory..."
cd "$PROJECT_ROOT/ansible"
echo "[proxy]" > hosts
echo "$PROXY_IP ansible_user=$SSH_USER ansible_ssh_private_key_file=$KEY_PATH" >> hosts

# Wait for VM to be ready
echo "Waiting for VM SSH to become available..."
until ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" -q "$SSH_USER@$PROXY_IP" exit; do
  printf "."
  sleep 5
done
echo "SSH is now available!"

# Run Ansible to install NGINX on the VM
echo "Running Ansible playbook (NGINX install only)..."
ansible-playbook -i hosts nginx-proxy.yml

echo "Done! NGINX should now be running at http://$PROXY_IP"