output "nginx_mig_id" {
  value = google_compute_region_instance_group_manager.nginx_mig.instance_group
}

output "gce_sa_email" {
  description = "GCE SA Email"
  value       = google_service_account.vm_sa.email
}
