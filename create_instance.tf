data "openstack_compute_availability_zones_v2" "zones" {}

data "openstack_networking_network_v2" "network" {
  name = var.network_name
}

resource "tls_private_key" "key" {
  count = var.create_key_pair_name != null && var.ssh_public_key == null && var.ssh_public_key_file == null ? 1 : 0
  algorithm   = "RSA"
  rsa_bits = "2048"
}

data "openstack_images_image_ids_v2" "get_image" {
  name_regex = local.regex_list["${var.OS}"]
  sort       = "updated_at"
}

resource "openstack_compute_keypair_v2" "create_key_pair" {
  count      = var.create_key_pair_name != null ? 1 : 0
  name       = var.create_key_pair_name
  public_key = local.public_key
}

resource "openstack_networking_secgroup_v2" "create_security_group" {
  count       = var.create_security_group_name == null ? 0 : 1
  name        = var.create_security_group_name
  description = "my ${var.create_security_group_name} security group"
}

# resource "openstack_networking_secgroup_rule_v2" "create_secgroup_rule" {
#   count             = var.security_group_rules != null ? length(var.security_group_rules) : 0
#   direction         = var.vm_info.security_group.security_group_rules[count.index].direction
#   ethertype         = var.vm_info.security_group.security_group_rules[count.index].ethertype
#   protocol          = var.vm_info.security_group.security_group_rules[count.index].protocol
#   port_range_min    = var.vm_info.security_group.security_group_rules[count.index].port_range_min
#   port_range_max    = var.vm_info.security_group.security_group_rules[count.index].port_range_max
#   remote_ip_prefix  = var.vm_info.security_group.security_group_rules[count.index].remote_ip_prefix
#   security_group_id = local.security_group_flag == 1 ? "${openstack_networking_secgroup_v2.create_security_group[0].id}" : jsondecode(data.http.get_security_groups_list.response_body)["security_groups"].0.id
# }

resource "openstack_compute_instance_v2" "nhn_create_instance" {
  name              = var.vm_name
  image_id          = data.openstack_images_image_ids_v2.get_image.ids[0]
  region            = var.region
  flavor_name       = var.flavor_name
  key_pair          = var.create_key_pair_name != null ? openstack_compute_keypair_v2.create_key_pair[0].name : var.key_pair_name
  availability_zone = data.openstack_compute_availability_zones_v2.zones.names[0]
  network {
    uuid = data.openstack_networking_network_v2.network.id
  }
  security_groups = local.security_groups
  block_device {
    uuid                  = data.openstack_images_image_ids_v2.get_image.ids[0]
    source_type           = "image"
    destination_type      = local.destination_type
    boot_index            = 0
    volume_size           = local.boot_size
    volume_type           = "General SSD"
    delete_on_termination = true
  }
  user_data = var.user_data_file_path != null  ? fileexists(var.user_data_file_path) != false ? base64encode(file(var.user_data_file_path)) : null : null
}

resource "openstack_compute_floatingip_v2" "floatingip" {
  pool = "Public Network"
}

resource "openstack_compute_floatingip_associate_v2" "fip_associate" {
  floating_ip = openstack_compute_floatingip_v2.floatingip.address
  instance_id = openstack_compute_instance_v2.nhn_create_instance.id
}

resource "openstack_blockstorage_volume_v2" "volume" {
  count             = length(var.additional_volumes)
  name              = "${var.vm_name}_${count.index}"
  size              = var.additional_volumes[count.index]
  availability_zone = data.openstack_compute_availability_zones_v2.zones.names[0]
  volume_type       = "General SSD"
}

resource "openstack_compute_volume_attach_v2" "attach_volume" {
  count       = length(var.additional_volumes)
  instance_id = openstack_compute_instance_v2.nhn_create_instance.id
  volume_id   = openstack_blockstorage_volume_v2.volume[count.index].id
  vendor_options {
    ignore_volume_confirmation = true
  }
}