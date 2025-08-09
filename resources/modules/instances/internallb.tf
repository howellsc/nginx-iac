resource "google_compute_subnetwork" "nginx_proxy_only" {
  name    = "${var.name}-inginx-proxy-subnet"
  ip_cidr_range = "10.129.0.0/23"  # must be in your VPC range
  region  = var.region
  network = var.vpc_name
  purpose = "REGIONAL_MANAGED_PROXY"
  role    = "ACTIVE"
}

resource "google_compute_backend_service" "nginx_internal_backend" {
  name                  = "${var.name}-internal-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "INTERNAL_MANAGED"
  health_checks = [google_compute_health_check.nginx_http_health_check.self_link]

  backend {
    group = google_compute_instance_group_manager.nginx_mig.self_link
  }
}

resource "google_compute_url_map" "nginx_url_map" {
  name            = "${var.name}-nginx-url-map"
  default_service = google_compute_backend_service.nginx_internal_backend.self_link
}

resource "google_compute_target_http_proxy" "nginx_http_proxy" {
  name    = "${var.name}-nginx-http-proxy"
  url_map = google_compute_url_map.nginx_url_map.self_link
}

resource "google_compute_forwarding_rule" "nginx_forwarding_rule" {
  name                  = "${var.name}-nginx-http-forwarding-rule"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.nginx_http_proxy.self_link
  network               = var.vpc_name
  subnetwork            = google_compute_subnetwork.nginx_proxy_only.self_link
  ip_protocol           = "TCP"
  region                = var.region
}


