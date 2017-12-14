


resource "google_compute_firewall" "allow-https" {
    name = "allow-https"
    network = "default"

    allow {
        protocol = "tcp"
        ports = ["443"]
    }

    source_ranges = [
      "0.0.0.0/0"
    ]
    target_tags = [
      "${var.component}",
    ]
}

