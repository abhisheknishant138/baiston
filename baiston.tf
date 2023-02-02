# ---------------------------------------------------------------------------------------------------------------------
# Create an instance with OS Login configured to use as a bastion host.
# ---------------------------------------------------------------------------------------------------------------------

resource "google_compute_instance" "bastion_host" {
  project      = var.project
  name         = "Arm-instance"
  machine_type = "t2a-standard-1"
  zone         = var.zone

  tags = [var.tag]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts-arm64"
    }
  }

  network_interface {
    subnetwork = var.subnetwork

    // If var.static_ip is set use that IP, otherwise this will generate an ephemeral IP
    access_config {
      nat_ip = var.static_ip
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
