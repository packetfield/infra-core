variable nat_ip { default = "undefined" }
variable component { default = "undefined" }
variable env { default = "testing" }
variable project { default = "undefined" }
variable region { default = "europe-west1" }
variable zone { default = "europe-west1-d" }
variable instance_name { default = "undefined-instance" }
variable size {
  description = "Target size of the instance"
  default = "f1-micro"
}

variable subnetwork_name {
  description = "Name of the subnetwork to deploy instances to"
  default = "default"
}

variable compute_machine_type {
  description = "Machine type for the VMs in the instance group"
  default = "n1-standard-1"
}

variable image {
  description = "Image used for compute VMs"
  default = "projects/debian-cloud/global/images/family/debian-9"
}

variable service_port {
  description = "TCP port your service is listening on."
  default = "80"
}

variable instance_id { default = "999" }

variable data_disk {
  description = "data volume path, ensure this is created before using this module"
}

/* output "external_ip" { */
/*   value = "${google_compute_forwarding_rule.compute.ip_address}" */
/* } */
