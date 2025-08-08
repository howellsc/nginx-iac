data "template_file" "nginx_startup_script" {
  template = file("${path.module}/scripts/startup.sh.tmpl")
  vars = {
    custom_message = var.custom_message
  }
}

resource "google_compute_instance" "nginx" {
  name = "nginx-container-vm"
  machine_type = "e2-micro"
  zone = var.zone

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network    = var.vpc_name
    subnetwork = var.vpc_subnet_name
  }

  metadata = {
    startup-script = data.template_file.nginx_startup_script.rendered
  }
}
