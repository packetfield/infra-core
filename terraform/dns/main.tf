#####################################
########### DNS
#####################################

resource "google_dns_managed_zone" "dns_zone_public" {
  description = "${var.project} (${var.env}) public zone - (managed by terraform"
  name        = "packetfield-${var.env}-public"
  dns_name    = "${var.env}.packetfield.com."
}
