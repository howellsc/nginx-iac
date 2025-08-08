locals {
  nginx_image = "gcr.io/${var.project_id}/nginx-static-site:v1"
}

data "template_file" "nginx_startup_script" {
  template = file("${path.module}/scripts/start-container.sh.tmpl")
  vars = {
    container_name = "nginx"
    image          = local.nginx_image
  }
}

resource "google_compute_instance" "nginx" {
  name         = "nginx-container-vm"
  machine_type = "e2-micro"
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = var.vpc_subnet_name
  }

  tags = [
    "allow-http-80-ingress",
    "allow-tcp-22-ingress"
  ]

  metadata = {
    startup-script = data.template_file.nginx_startup_script.rendered
  }
}
