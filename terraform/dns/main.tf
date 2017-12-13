#####################################
########### DNS
#####################################

resource "google_dns_managed_zone" "dns_zone_public" {
  description = "${var.env} public zone [see: terraform/${var.component}]"
  name        = "${var.project}-${var.env}-public"
  dns_name    = "${var.public_dns_name}"
}
