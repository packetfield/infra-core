terraform {
  backend "gcs" {
  }


provider "google" {
  project     = "${var.project}"
  region      = "${var.region}"
}
