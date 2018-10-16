
resource "google_service_account" "dns" {
  account_id   = "${var.env}-${var.component}-dns"
  display_name = "${var.env}-${var.component}-dns"
}

resource "google_service_account_key" "dns" {
  service_account_id = "${google_service_account.dns.name}"
  public_key_type = "TYPE_X509_PEM_FILE"
  private_key_type = "TYPE_GOOGLE_CREDENTIALS_FILE"
}


resource "google_project_iam_member" "dns" {
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.dns.email}"
}

output "key_dns" {
  # NOTE... will be base64 encoded..
  value = "${google_service_account_key.dns.private_key}"
}
