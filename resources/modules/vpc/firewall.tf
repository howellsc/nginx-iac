resource "google_compute_firewall" "http-ingress" {

  allow {
    ports = [
      "80"
    ]
    protocol = "tcp"
  }

  direction = "INGRESS"
  name      = "${var.name}-vpc-http-ingress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    google_compute_subnetwork.subnet_nginx.ip_cidr_range
  ]
  target_tags = [
    "${var.name}-allow-http-80-ingress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "https-ingress" {

  allow {
    ports = [
      "443"
    ]
    protocol = "tcp"
  }

  direction = "INGRESS"
  name      = "${var.name}-vpc-https-ingress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    google_compute_subnetwork.subnet_nginx.ip_cidr_range
  ]
  target_tags = [
    "${var.name}-allow-https-443-ingress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "https-egress" {

  allow {
    ports = [
      "443"
    ]
    protocol = "tcp"
  }

  direction = "EGRESS"
  name      = "${var.name}-vpc-https-egress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    google_compute_subnetwork.subnet_nginx.ip_cidr_range
  ]
  target_tags = [
    "${var.name}-allow-https-443-egress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "http-egress" {

  allow {
    ports = [
      "80",
      "8080"
    ]
    protocol = "tcp"
  }

  direction = "EGRESS"
  name      = "${var.name}-vpc-http-egress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    google_compute_subnetwork.subnet_nginx.ip_cidr_range
  ]
  target_tags = [
    "${var.name}-allow-https-80-8080-egress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}

resource "google_compute_firewall" "ssh-ingress" {
  allow {
    ports = [
      "22",
    ]
    protocol = "tcp"
  }

  direction = "INGRESS"
  name      = "${var.name}-vpc-ssh-ingress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    google_compute_subnetwork.subnet_nginx.ip_cidr_range
  ]
  target_tags = [
    "${var.name}-allow-tcp-22-ingress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}
