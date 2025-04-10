#!/bin/bash

set -euo pipefail

# ────── PATHS & VARIABLES ──────
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEY_DIR="$PROJECT_ROOT/.ssh"
KEY_PATH="$KEY_DIR/id_rsa"
PUB_KEY_PATH="${KEY_PATH}.pub"
SSH_USER="debian"
INGRESS_NAME="ingress"

# ────── ROTATE SSH KEY ──────
echo "Rotating SSH key..."
rm -f "$KEY_PATH" "$PUB_KEY_PATH"
mkdir -p "$KEY_DIR"
ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N "" -C "terraform@proxy" <<< y > /dev/null

# ────── TERRAFORM ──────
echo "Running Terraform..."
terraform -chdir="$PROJECT_ROOT/terraform" init
terraform -chdir="$PROJECT_ROOT/terraform" apply \
  -var="ssh_user=$SSH_USER" \
  -var="ssh_public_key_path=$PUB_KEY_PATH" \
  -auto-approve

# ────── EXTRACT OUTPUTS ──────
echo "Getting public IPs from Terraform..."
PROXY_IP=$(terraform -chdir="$PROJECT_ROOT/terraform" output -raw proxy_ip)
CLUSTER_NAME=$(terraform -chdir="$PROJECT_ROOT/terraform" output -raw cluster_name)
CLUSTER_LOCATION=$(terraform -chdir="$PROJECT_ROOT/terraform" output -raw location)

# ────── CONNECT TO GKE ──────
echo "Connecting to GKE Cluster..."
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$CLUSTER_LOCATION"

# ────── DEPLOY APP TO GKE ──────
echo "Deploying app to Kubernetes..."
kubectl apply -f "$PROJECT_ROOT/k8s"

# ────── WAIT FOR INGRESS IP ──────
echo "Waiting for external IP on ingress '$INGRESS_NAME'..."
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

# ────── CREATE ANSIBLE INVENTORY ──────
echo "Creating Ansible inventory..."
cd "$PROJECT_ROOT/ansible"
echo "[proxy]" > hosts
echo "$PROXY_IP ansible_user=$SSH_USER ansible_ssh_private_key_file=$KEY_PATH" >> hosts

# ────── WAIT FOR SSH ON VM ──────
 echo "Waiting for VM SSH to become available..."
 until ssh -o StrictHostKeyChecking=no -i "$KEY_PATH" -q "$SSH_USER@$PROXY_IP" exit; do
   printf "."
   sleep 5
 done
 echo "SSH is now available!"

# ────── RUN ANSIBLE ──────
echo "Running Ansible playbook..."
ansible-playbook -i hosts nginx-proxy.yml \
  --extra-vars "domain=$INGRESS_IP ingress_ip=$INGRESS_IP" -vv

# ────── DONE ──────
echo "🎉 Deployment complete! Visit: http://$INGRESS_IP"