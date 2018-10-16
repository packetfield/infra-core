# A key for use with sops
resource "google_kms_key_ring" "kms_key_sops" {
  project  = "${var.project}"
  name     = "${var.env}-${var.component}-sops"
  location = "global"
}

resource "google_kms_crypto_key" "kms_key_sops" {
  name     = "${var.env}-${var.component}-sops"
  key_ring = "${google_kms_key_ring.kms_key_sops.id}"
}
