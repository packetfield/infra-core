
output "internal_ip" {
  value = "${module.instance1.internal_ip}"
}

output "network_ip" {
  value = "${module.instance1.network_ip}"
}

output "nat_ip" {
  value = "${module.instance1.nat_ip}"
}

output "assigned_nat_ip" {
  value = "${module.instance1.assigned_nat_ip}"
}

