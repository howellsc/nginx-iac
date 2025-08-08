locals {
  nginx_image     = "gcr.io/${var.project_id}/nginx-static-site:v1"
  nginx_instances = 1
}

# Create the service account
resource "google_service_account" "vm_sa" {
  account_id   = "vm-service-account"
  display_name = "VM Service Account"
}

# Give it access to GCR (Google Container Registry)
resource "google_project_iam_member" "gcr_access" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

resource "google_project_iam_member" "logwriter_access" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.vm_sa.email}"
}

# resource "google_artifact_registry_repository_iam_binding" "artifact_registry_access" {
#   members = ["serviceAccount:${google_service_account.vm_sa.email}"]
#   location   = "us"
#   repository = "gcr.io"
#   role       = "roles/artifactregistry.reader"
# }

data "template_file" "nginx_startup_script" {
  template = file("${path.module}/scripts/start-container.sh.tmpl")
  vars = {
    container_name = "nginx"
    image          = local.nginx_image
  }
}

resource "google_compute_instance_template" "nginx_template" {
  name         = "nginx-container-vm"
  machine_type = "e2-micro"
  region       = var.region


  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
    type         = "PERSISTENT"
    disk_size_gb = 10
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

resource "google_compute_instance_group_manager" "gce_nomad_mig" {
  name = "gce-nomad-mig"

  zone               = var.zone
  base_instance_name = "nginx"
  version {
    instance_template = google_compute_instance_template.nginx_template.id
  }
  target_size = local.nginx_instances # Number of backend instances

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.nginx_http.id
    initial_delay_sec = 60
  }

  lifecycle {
    replace_triggered_by = [google_compute_instance_template.nginx_template]
  }

  depends_on = [google_compute_instance_template.nginx_template]
}

resource "google_compute_health_check" "nginx_http" {
  name                = "nginx-http-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    request_path = "/"
    port_name    = "http"
  }
}
