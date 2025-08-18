resource "google_compute_subnetwork" "nginx_proxy_only" {
  name          = "${var.name}-inginx-proxy-subnet"
  ip_cidr_range = "10.129.0.0/23" # must be in your VPC range
  region        = var.region
  network       = var.vpc_name
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

resource "google_compute_region_url_map" "nginx_url_map" {
  name            = "${var.name}-nginx-url-map"
  default_service = google_compute_region_backend_service.nginx_gce_neg_backend.self_link
  region          = var.region

  host_rule {
    hosts        = ["*"]
    path_matcher = "all-paths"
  }

  path_matcher {
    name            = "all-paths"
    default_service = google_compute_region_backend_service.nginx_gce_neg_backend.self_link

    path_rule {
      paths = ["/mig/*"]
      # route_action {
      #   url_rewrite {
      #   }
      # }
      service = google_compute_region_backend_service.nginx_gce_mig_backend.self_link
    }

    path_rule {
      paths = ["/neg/*"]
      # route_action {
      #   url_rewrite {
      #   }
      # }
      service = google_compute_region_backend_service.nginx_gce_neg_backend.self_link
    }
  }

}

resource "google_compute_region_target_http_proxy" "nginx_http_proxy" {
  name    = "${var.name}-nginx-http-proxy"
  url_map = google_compute_region_url_map.nginx_url_map.self_link
  region  = var.region
}

resource "google_compute_forwarding_rule" "nginx_forwarding_rule" {
  name                  = "${var.name}-nginx-http-forwarding-rule"
  load_balancing_scheme = "INTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_region_target_http_proxy.nginx_http_proxy.self_link
  network               = var.vpc_name
  subnetwork            = var.vpc_subnet_name
  ip_protocol           = "TCP"
  region                = var.region

  depends_on = [
    google_compute_subnetwork.nginx_proxy_only
  ]
}

resource "google_compute_region_health_check" "nginx_http_health_check" {
  name                = "${var.name}-nginx-http-health-check"
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3
  region              = var.region

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

  health_checks = [google_compute_region_health_check.nginx_http_health_check.self_link]

  backend {
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1
    group           = var.nginx_backend_mig_id
  }
}

resource "google_compute_region_backend_service" "nginx_gce_neg_backend" {
  name                  = "${var.name}-neg-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "INTERNAL_MANAGED"
  region                = var.region

  health_checks = [google_compute_region_health_check.nginx_http_health_check.self_link]

  backend {
    group = var.nginx_backend_neg_id
  }
}
