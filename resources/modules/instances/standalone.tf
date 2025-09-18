# Reserve an internal IP
resource "google_compute_address" "internal_ip_nginx_standalone" {
  name         = "${var.name}-nginx-internal-ip"
  subnetwork   = var.vpc_subnet_name
  address_type = "INTERNAL"
  region       = var.region
}

# NGINX VM
resource "google_compute_instance" "nginx_standalone" {
  name         = "${var.name}-nginx-internal"
  machine_type = "e2-micro"
  zone         = var.zone
  tags = [
    "${var.name}-allow-http-80-ingress",
    "${var.name}-allow-https-443-ingress",
    "${var.name}-allow-tcp-22-ingress",
    "${var.name}-allow-https-443-egress"
  ]

  shielded_instance_config {
    enable_secure_boot = true
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  service_account {
    email  = google_service_account.vm_sa.email
    scopes = ["cloud-platform"]
  }

  network_interface {
    subnetwork = var.vpc_subnet_name
    network_ip = google_compute_address.internal_ip_nginx_standalone.address
  }

  allow_stopping_for_update = true

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

    cat <<EOF > /var/www/html/index.html
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <title>Welcome to NGINX</title>
      <style>
        body {
          font-family: Arial, sans-serif;
          background: #f5f5f5;
          color: #333;
          text-align: center;
          margin-top: 100px;
        }
        h1 {
          color: #2d8cf0;
        }
      </style>
    </head>
    <body>
      <h1>Welcome to NGINX</h1>
      <p>Your server is running and serving content over HTTPS on the standalone instance</p>
    </body>
    </html>
    EOF

    # Set permissions
    chown -R www-data:www-data /var/www/html
    chmod -R 755 /var/www/html

    systemctl restart nginx
  EOT
}
