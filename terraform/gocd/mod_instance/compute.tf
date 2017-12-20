
resource "google_compute_instance" "default" {
  name         = "${var.env}-${var.component}-${var.instance_id}"
  machine_type = "${var.size}"
  zone         = "${var.zone}"
  tags = [
    "${var.env}",
    "${var.component}",
    "id-${var.instance_id}"
    ]
  boot_disk{
    initialize_params {
      size  = 10
      image = "${var.image}"
    }
  }

  attached_disk {
    source = "${var.data_disk}"
  }

  network_interface {
    network = "default"
    access_config {
      // gimme a public NAT IP
      nat_ip = "${var.nat_ip}"
    }
  }

 service_account {
    scopes = [
      "${var.scopes}"
    ]
  }
}

output "internal_ip" {
  value = "${google_compute_instance.default.network_interface.0.address}"
}

output "network_ip" {
  value = "${google_compute_instance.default.network_interface.0.network_ip}"
}

output "nat_ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

output "assigned_nat_ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.assigned_nat_ip}"
}
