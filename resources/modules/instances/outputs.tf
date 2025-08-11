output "nginx_mig_id" {
  value = google_compute_region_instance_group_manager.nginx_mig.instance_group
}