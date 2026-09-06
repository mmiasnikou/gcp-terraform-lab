output "network_name" {
  value = google_compute_network.lab.name
}

output "subnet_cidr" {
  value = google_compute_subnetwork.lab.ip_cidr_range
}

output "vm_internal_ip" {
  value = var.enable_vm ? google_compute_instance.lab[0].network_interface[0].network_ip : null
}
