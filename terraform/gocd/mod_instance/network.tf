


resource "google_compute_firewall" "allow-https" {
    name = "${var.env}-${var.component}-allow-https"
    network = "default"

    allow {
        protocol = "tcp"
        ports = [
          "80",
          "443",
          "8153",
        ]
    }

    source_ranges = [
      "0.0.0.0/0"
    ]
    target_tags = [
      "${var.component}",
    ]
}

