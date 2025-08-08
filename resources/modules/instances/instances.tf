locals {
  nginx_image = "gcr.io/${var.project_id}/nginx-static-site:v1"
}

# Create the service account
resource "google_service_account" "vm_sa" {
  account_id   = "vm-service-account"
  display_name = "VM Service Account"
}

# Give it access to GCR (Google Container Registry)
resource "google_project_iam_member" "gcr_access" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_artifact_registry_repository_iam_binding" "artifact_registry_access" {
  members = ["serviceAccount:${google_service_account.vm_sa.email}"]
  location   = "us"
  repository = "gcr.io/${var.project_id}"
  role       = "roles/artifactregistry.reader"
}

data "template_file" "nginx_startup_script" {
  template = file("${path.module}/scripts/start-container.sh.tmpl")
  vars = {
    container_name = "nginx"
    image          = local.nginx_image
  }
}

resource "google_compute_instance" "nginx" {
  name         = "nginx-container-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = var.vpc_subnet_name
  }

  service_account {
    email = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  tags = [
    "allow-http-80-ingress",
    "allow-tcp-22-ingress",
    "allow-https-443-egress"
  ]

  metadata = {
    startup-script = data.template_file.nginx_startup_script.rendered
  }
}
