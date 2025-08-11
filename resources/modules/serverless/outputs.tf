output "nginx_neg_id" {
  value = google_compute_region_network_endpoint_group.nginx_cloudrun_neg.self_link
}

output "cloud_run_sa_email" {
  value = google_service_account.cloud_run_sa.email
}