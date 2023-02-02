terraform {
  # This module is now only being tested with Terraform 1.0.x. However, to make upgrading easier, we are setting
  # 0.12.26 as the minimum version, as that version added support for required_providers with source URLs, making it
  # forwards compatible with 1.0.x code.
  required_version = ">= 0.12.26"
}

# ---------------------------------------------------------------------------------------------------------------------
# Create a Management Network for shared services
# ---------------------------------------------------------------------------------------------------------------------

module "management_network" {
  name_prefix = "bastion"
  project     = var.project
  region      = var.region
}

# ---------------------------------------------------------------------------------------------------------------------
# Create the bastion host to access private instances
# ---------------------------------------------------------------------------------------------------------------------

module "bastion_host" {

  instance_name = "bastion-vm"
  subnetwork    = module.management_network.public_subnetwork

  project = var.project
  zone    = var.zone
}

# ---------------------------------------------------------------------------------------------------------------------
# Create a private instance to use alongside the bastion host.
# ---------------------------------------------------------------------------------------------------------------------

  resource "google_compute_instance" "private" {
  name         = "bastion-private"
  machine_type = "t2a-standard-1"
  zone         = var.zone

  allow_stopping_for_update = true

  tags = [module.management_network.private]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts-arm64"
    }
  }

  network_interface {
    subnetwork = module.management_network.private_subnetwork
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
