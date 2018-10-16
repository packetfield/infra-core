
resource "google_service_account" "shippable" {
  account_id   = "${var.env}-${var.component}-shippable"
  display_name = "${var.env}-${var.component}-shippable"
}

resource "google_service_account_key" "shippable" {
  service_account_id = "${google_service_account.shippable.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
  private_key_type = "TYPE_GOOGLE_CREDENTIALS_FILE"
}


resource "google_project_iam_member" "shippable" {
  role    = "roles/storage.admin"  # +RW access to GCR
  member  = "serviceAccount:${google_service_account.shippable.email}"
}

output "key_shippable" {
  # NOTE... will be base64 encoded..
  value = "${google_service_account_key.shippable.private_key}"
}
