# A dedicated service account instead of the default compute SA,
# which carries considerably more permissions than this VM needs.
# No service account keys are created.
resource "google_service_account" "vm" {
  account_id   = "lab-vm-sa"
  display_name = "Lab VM service account"
}

resource "google_project_iam_member" "vm_logging" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm.email}"
}

resource "google_project_iam_member" "vm_monitoring" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.vm.email}"
}
