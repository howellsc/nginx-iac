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
    startup-script = file("./startup-scripts/startup_script.sh")
  }
}
