resource "google_compute_instance" "lab" {
  count        = var.enable_vm ? 1 : 0
  name         = "lab-vm"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = ["lab-vm"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.lab.id
    # No access_config block on purpose: the VM gets no external IP.
  }

  service_account {
    email  = google_service_account.vm.email
    scopes = ["cloud-platform"]
  }
}
