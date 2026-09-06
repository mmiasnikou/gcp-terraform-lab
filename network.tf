resource "google_compute_network" "lab" {
  name                    = "lab-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "lab" {
  name                     = "lab-subnet"
  network                  = google_compute_network.lab.id
  region                   = var.region
  ip_cidr_range            = var.subnet_cidr
  private_ip_google_access = true
}

# SSH over IAP only. The range belongs to Google and is not reachable from the internet.
resource "google_compute_firewall" "ssh_from_iap" {
  name          = "allow-ssh-from-iap"
  network       = google_compute_network.lab.name
  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["lab-vm"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

# Cloud NAT is only needed while the VM exists: it has no external IP,
# but still needs outbound access for package updates and the like.
resource "google_compute_router" "lab" {
  count   = var.enable_vm ? 1 : 0
  name    = "lab-router"
  region  = var.region
  network = google_compute_network.lab.id
}

resource "google_compute_router_nat" "lab" {
  count                              = var.enable_vm ? 1 : 0
  name                               = "lab-nat"
  router                             = google_compute_router.lab[0].name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
