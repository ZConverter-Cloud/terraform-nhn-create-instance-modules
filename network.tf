resource "openstack_networking_secgroup_v2" "create_security_group" {
  count       = var.create_security_group_name != null ? 1 : 0
  name        = "${var.create_security_group_name}_${random_string.random_string.result}"
  description = "my ${var.create_security_group_name}_${random_string.random_string.result} security group"
}

resource "openstack_networking_secgroup_rule_v2" "secgroup_rule_1" {
  count            = var.create_security_group_rules != null ? length(var.create_security_group_rules) : 0
  direction        = var.create_security_group_rules[count.index].direction
  ethertype        = var.create_security_group_rules[count.index].ethertype
  protocol         = var.create_security_group_rules[count.index].protocol
  port_range_min   = var.create_security_group_rules[count.index].port_range_min
  port_range_max   = var.create_security_group_rules[count.index].port_range_max
  remote_ip_prefix = var.create_security_group_rules[count.index].remote_ip_prefix
  security_group_id = var.create_security_group_name != null ? openstack_networking_secgroup_v2.create_security_group[0].id : data.openstack_networking_secgroup_v2.get_security_group_id[0].id
}

resource "openstack_compute_floatingip_v2" "floatingip" {
  pool = "Public Network"
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  floating_ip = openstack_compute_floatingip_v2.floatingip.address
  instance_id = openstack_compute_instance_v2.nhn_create_instance.id
}
