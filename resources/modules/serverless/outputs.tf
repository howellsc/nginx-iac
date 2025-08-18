output "nginx_neg_id" {
  value = google_compute_region_network_endpoint_group.nginx_cloudrun_neg.self_link
}
