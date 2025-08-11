resource "google_compute_subnetwork" "nginx_proxy_only" {
  name    = "${var.name}-inginx-proxy-subnet"
  ip_cidr_range = "10.129.0.0/23"  # must be in your VPC range
  region  = var.region
  network = var.vpc_name
  purpose = "REGIONAL_MANAGED_PROXY"
  role    = "ACTIVE"
}

resource "google_compute_url_map" "nginx_url_map" {
  name            = "${var.name}-nginx-url-map"
  default_service = google_compute_region_backend_service.nginx_gce_mig_backend.self_link

  host_rule {
    hosts = ["*"]
    path_matcher = "path-matcher-1"
  }

  path_matcher {
    name            = "path-matcher-1"
    default_service = google_compute_region_backend_service.nginx_gce_mig_backend.self_link

    path_rule {
      paths = ["/mig/*"]
      service = google_compute_region_backend_service.nginx_gce_mig_backend.self_link
    }

    path_rule {
      paths = ["/neg/*"]
      service = google_compute_region_backend_service.nginx_gce_neg_backend.self_link
    }
  }

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

resource "google_compute_health_check" "nginx_http_health_check" {
  name                = "${var.name}-nginx-http-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    request_path = "/"
    port_name    = "http"
  }
}

resource "google_compute_region_backend_service" "nginx_gce_mig_backend" {
  name                  = "${var.name}-mig-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "INTERNAL_MANAGED"
  region                = var.region

  health_checks = [google_compute_health_check.nginx_http_health_check.self_link]

  backend {
    group = var.nginx_backend_mig_id
  }
}

resource "google_compute_region_backend_service" "nginx_gce_neg_backend" {
  name                  = "${var.name}-internal-neg-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "INTERNAL_MANAGED"
  region                = var.region

  backend {
    group = var.nginx_backend_neg_id
  }
}