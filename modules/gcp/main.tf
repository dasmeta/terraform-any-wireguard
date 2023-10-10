# Prepare wireguard server and clients configs
module "wg_configs" {
  source = "../wg-configs"

  server_public_ip   = google_compute_address.this.address
  server_private_key = var.server_private_key
  server_public_key  = var.server_public_key
  clients            = var.clients
}

# Create firewall rules allowing access to the instance
resource "google_compute_firewall" "this" {
  name        = "${var.name}-firewall-rule"
  network     = var.vpc_name
  description = "Wireguard instance inbound/outbound rules"

  allow {
    protocol = "udp"
    ports    = [var.server_port]
  }

  dynamic "allow" {
    for_each = length(var.ssh_keys) > 0 ? [1] : []

    content {
      ports    = [22]
      protocol = "tcp"
    }
  }

  source_ranges = var.ingress
  target_tags   = ["wireguard", var.name]
}

# create static/elastic IP and attach to wireguard server instance
resource "google_compute_address" "this" {
  name   = "${var.name}-static-ip-address"
  region = var.region
}

# Provision wireguard server instance
resource "google_compute_instance" "this" {
  name         = var.name
  machine_type = var.instance_type
  zone         = var.zone
  boot_disk {
    initialize_params {
      image = var.ubuntu_version
    }
  }

  network_interface {
    network = var.vpc_name
    access_config {
      nat_ip = google_compute_address.this.address
    }
  }

  metadata_startup_script = module.wg_configs.startup_script

  tags = ["wireguard", var.name]

  metadata = {
    ssh-keys = join("\n", [for ssh in var.ssh_keys : "${ssh.username}:${ssh.public_key}"])
  }
}
