resource "google_service_account" "cloud_run_sa" {
  account_id   = "${var.name}-cloud-run-sa"
  display_name = "${var.name} Cloud Run Service Account"
}

# Allow Cloud Run to pull private images from Artifact Registry
resource "google_project_iam_member" "artifact_registry_access" {
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
  project = var.project_id
}

# Allow unauthenticated access
resource "google_cloud_run_service_iam_member" "noauth" {
  location = google_cloud_run_v2_service.nginx_serverless.location
  project  = var.project_id
  service  = google_cloud_run_v2_service.nginx_serverless.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.cloud_run_sa_email}"
}

# Deploy the container to Cloud Run
resource "google_cloud_run_v2_service" "nginx_serverless" {
  name                = "${var.name}-nginx-serverless"
  location            = var.region
  ingress             = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  deletion_protection = false

  template {
    service_account = google_service_account.cloud_run_sa.email

    containers {
      image = var.nginx_image_url

      ports {
        container_port = 80
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "nginx_cloudrun_neg" {
  name                  = "${var.name}-nginx-cloudrun-neg"
  region                = var.region
  network_endpoint_type = "SERVERLESS"

  cloud_run {
    service = google_cloud_run_v2_service.nginx_serverless.name
  }
}