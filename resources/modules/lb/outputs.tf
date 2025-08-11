output "nginx_healthcheck_id" {
  value = google_compute_region_health_check.nginx_http_health_check.self_link
}