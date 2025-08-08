output "vpc_name" {
  value = google_compute_network.vpc.id
}

output "vpc_subnet_name" {
  value = google_compute_subnetwork.subnet_nginx.id
}