locals {
  nginx_instances = 1
}

data "template_file" "nginx_startup_script" {
  template = file("${path.module}/scripts/start-container.sh.tmpl")
  vars = {
    container_name = "nginx"
    image          = var.nginx_image_url
  }
}

resource "google_compute_instance_template" "nginx_template" {
  name         = "${var.name}-nginx-container-vm"
  machine_type = "e2-micro"
  region       = var.region


  disk {
    source_image = "cos-cloud/cos-stable"
    auto_delete  = true
    boot         = true
    type         = "PERSISTENT"
    disk_size_gb = 10
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = var.vpc_subnet_name
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  tags = [
    "${var.name}-allow-http-80-ingress",
    "${var.name}-allow-tcp-22-ingress",
    "${var.name}-allow-https-443-egress"
  ]

  metadata = {
    startup-script = data.template_file.nginx_startup_script.rendered
  }
}

resource "google_compute_region_instance_group_manager" "nginx_mig" {
  name = "${var.name}-nginx-mig"

  region             = var.region
  base_instance_name = "${var.name}-nginx"
  version {
    instance_template = google_compute_instance_template.nginx_template.id
  }
  target_size = local.nginx_instances # Number of backend instances

  named_port {
    name = "http"
    port = 80
  }

  auto_healing_policies {
    health_check      = var.nginx_healthcheck_id
    initial_delay_sec = 120
  }

  lifecycle {
    replace_triggered_by = [google_compute_instance_template.nginx_template]
  }

  depends_on = [google_compute_instance_template.nginx_template]
}
