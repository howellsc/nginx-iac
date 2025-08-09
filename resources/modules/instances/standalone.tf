# Reserve an internal IP
resource "google_compute_address" "internal_ip_nginx_standalone" {
  name         = "${var.name}-nginx-internal-ip"
  subnetwork   = var.vpc_name
  address_type = "INTERNAL"
  region       = var.region
}

# NGINX VM
resource "google_compute_instance" "nginx_standalone" {
  name         = "${var.name}-nginx-internal"
  machine_type = "e2-micro"
  zone         = var.zone
  tags = ["${var.name}-allow-https-443-egress"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = var.vpc_subnet_name
    network_ip = google_compute_address.internal_ip_nginx_standalone.address
    access_config {
      nat_ip = null
    }
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx openssl

    mkdir -p /etc/nginx/ssl

    openssl req -x509 -nodes -days 365 \
      -subj "/CN=nginx.internal" \
      -newkey rsa:2048 \
      -keyout /etc/nginx/ssl/selfsigned.key \
      -out /etc/nginx/ssl/selfsigned.crt

    cat > /etc/nginx/sites-available/default <<EOF
    server {
        listen 443 ssl;
        server_name _;

        ssl_certificate     /etc/nginx/ssl/selfsigned.crt;
        ssl_certificate_key /etc/nginx/ssl/selfsigned.key;

        location / {
            root /var/www/html;
            index index.html;
        }
    }
    EOF

    systemctl restart nginx
  EOT
}