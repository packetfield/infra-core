
# https://www.terraform.io/docs/providers/google/r/container_cluster.html
resource "google_container_cluster" "default" {
  description        = "${var.description}"
  name               = "${var.cluster_name}"
  zone               = "${var.zone}"
  initial_node_count = 2
  enable_legacy_abac = false

  additional_zones = [
    /* "${var.region}-a", */
    /* "${var.region}-c", */
  ]

    maintenance_policy {
      daily_maintenance_window {
        start_time = "03:00"
       }
    }

    addons_config {

      http_load_balancing {
        disabled = false
      }

      horizontal_pod_autoscaling {
        disabled = false
      }
    }

  node_config {
    image_type   = "UBUNTU"
    disk_size_gb = "${var.disk_size}"
    machine_type = "${var.machine_type}"
    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels {
      component = "${var.component}",
      env       = "${var.env}",
    }

    tags = [
      /* "${var.component}", */
      "${var.env}-${var.component}",
      /* "env-${var.env}", */
      /* "component-${var.component}", */
    ]
  }
}

