# Create the service account
resource "google_service_account" "vm_sa" {
  account_id   = "${var.name}-vm-service-account"
  display_name = "${var.name} VM Service Account"
}

# Give it access to Artifact Registry
resource "google_project_iam_member" "artifactregistry_access" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_project_iam_member" "logwriter_access" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}
