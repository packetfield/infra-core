
#####################################
########### instance 1
#####################################
#disk for first instance
resource "google_compute_disk" "disk1" {
    name  = "${var.env}-${var.component}-1-data"
    type  = "pd-ssd"
    zone  = "${var.zone}"
    size  = "${var.data_volume_size}"
}

resource "google_compute_address" "default" {
  name = "${var.env}-${var.component}-static"
}

module "instance1" {
  instance_id    = "1"
  data_disk      = "${google_compute_disk.disk1.self_link}"
  size           = "${var.size}"
  component      = "${var.component}"
  env            = "${var.env}"
  zone           = "${var.zone}"
  region         = "${var.region}"
  project        = "${var.project}"
  source         = "github.com/packetfield/tfmod-instance-with-nat.git?ref=0.4"
  nat_ip         = "${google_compute_address.default.address}"
  scopes         = "${var.scopes}"
  boot_disk_size = 30
}


resource "google_compute_firewall" "http" {
    name = "${var.env}-${var.component}-http"
    network = "default"
    allow {
        protocol = "tcp"
        ports = [
          "80",
          "443",
        ]
    }
    source_ranges = [
      "0.0.0.0/0",
    ]
    target_tags = [
      "${var.env}-${var.component}",
    ]
}

# DNS records to find these hosts
resource "google_dns_record_set" "default" {
  name = "${var.component}.packetfield.com."
  type = "A"
  ttl  = 30
  managed_zone = "${var.project}-${var.env}-public"
  rrdatas = [
    "${google_compute_address.default.address}",
  ]
}

output "assigned_nat_ip" { value = "${module.instance1.assigned_nat_ip}" }
output "internal_ip"     { value = "${module.instance1.internal_ip}" }
output "nat_ip"          { value = "${module.instance1.nat_ip}" }
output "network_ip"      { value = "${module.instance1.network_ip}" }

