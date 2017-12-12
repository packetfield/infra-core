
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
      image = "${var.image}"
    }
  }

  attached_disk {
    source = "${var.data_disk}"
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

 service_account {
    scopes = [
      "compute-rw",  //access to discover other compute nodes
    ]
  }
}

output "internal_ip" {
  value = "${google_compute_instance.default.network_interface.0.address}"
}

