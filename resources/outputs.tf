output "debug_backend_mig_id" {
  value = module.gce_instances.nginx_mig_id
}

output "debug_backend_neg_id" {
  value = module.serverless.nginx_neg_id
}