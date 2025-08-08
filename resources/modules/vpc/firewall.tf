resource "google_compute_firewall" "http" {

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

resource "google_compute_firewall" "ssh" {
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