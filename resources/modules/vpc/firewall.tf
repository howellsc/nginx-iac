resource "google_compute_firewall" "http-ingress" {

  allow {
    ports = [
      "80"
    ]
    protocol = "tcp"
  }

  direction = "INGRESS"
  name      = "vpc-http-ingress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    "0.0.0.0/0"
  ]
  target_tags = [
    "allow-http-80-ingress"
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
  name      = "vpc-https-egress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    "0.0.0.0/0"
  ]
  target_tags = [
    "allow-https-443-egress"
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
  name      = "vpc-ssh-ingress"
  network   = google_compute_network.vpc.id
  priority  = 1000
  source_ranges = [
    "0.0.0.0/0"
  ]
  target_tags = [
    "allow-tcp-22-ingress"
  ]
  source_tags = []

  lifecycle {
    replace_triggered_by = [google_compute_network.vpc]
  }
}