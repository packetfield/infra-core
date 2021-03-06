
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

module "instance1" {
  instance_id   = "1"
  data_disk     = "${google_compute_disk.disk1.self_link}"
  size          = "${var.size}"
  component     = "${var.component}"
  env           = "${var.env}"
  zone          = "${var.zone}"
  region        = "${var.region}"
  project       = "${var.project}"
  source        = "./mod_instance"
}

#####################################
########### DNS
#####################################

/* # DNS records to find these hosts */
/* resource "google_dns_record_set" "default" { */
/*   name = "${var.component}.${var.env}.packetfield.com." */
/*   type = "A" */
/*   ttl  = 300 */
/*   managed_zone = "${var.project}-${var.env}-public" */
/*   rrdatas = [ */
/*     "${module.instance1.internal_ip}", */
/*   ] */
/* } */

