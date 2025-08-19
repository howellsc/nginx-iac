# NGINX VM
resource "google_compute_instance" "endpoint_tester" {
  name         = "${var.name}-endpoint-tester"
  machine_type = "e2-micro"
  zone         = var.zone
  tags = [
    "${var.name}-allow-https-443-egress", "${var.name}-allow-tcp-22-ingress", "${var.name}-allow-https-80-8080-egress"
  ]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  allow_stopping_for_update = true

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = var.vpc_subnet_name
  }
}
