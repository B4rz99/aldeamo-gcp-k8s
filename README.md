# Aldeamo GCP K8s Infrastructure

This project automates the provisioning, deployment, and secure exposure of a Kubernetes application using Google Cloud Platform (GCP), Terraform, Ansible, and Kubernetes (GKE).

It includes end-to-end infrastructure management, a TLS-terminating NGINX reverse proxy, and rate-limiting for incoming traffic.

⸻

🔧 Features
	GCP Infrastructure Provisioning (Terraform)
	•	VPC & Subnet creation
	•	Firewall rules for HTTP(S) & SSH
	•	GKE cluster with autoscaling
	•	Compute Engine VM for edge proxy

	Kubernetes Deployment
	•	Application manifests (Deployment, Service, Ingress)
	•	GKE Ingress exposing internal services

	NGINX Reverse Proxy (Ansible)
	•	Hosted on a Compute Engine VM
	•	Self-signed TLS certificate generation
	•	Secure reverse proxy to GKE Ingress
	•	Per-IP rate limiting (e.g. 10 req/s with burst)

	Secure Access
	•	HTTPS-only access to the reverse proxy
	•	Firewall rules limiting ingress traffic
	•	Custom rate-limiting logic to prevent abuse

	Automation Scripts
	•	deploy.sh – full infra provisioning, app deploy, and NGINX setup
	•	teardown.sh – clean teardown of infrastructure and local artifacts