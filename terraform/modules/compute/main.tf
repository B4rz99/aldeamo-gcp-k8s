resource "google_compute_instance" "proxy_instance" {
    name         = "proxy-instance"
    machine_type = "e2-micro"
    zone         = var.zone
    tags = ["proxy"]

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        network = var.network
        subnetwork = var.subnet
        access_config {}
    }

    depends_on = [var.subnet]

    metadata = {
        ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
    }
}