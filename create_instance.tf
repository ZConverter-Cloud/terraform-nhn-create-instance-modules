resource "random_string" "random_string" {
  length  = 5
  lower   = true
  special = false
  numeric  = false
  upper   = false
}

resource "openstack_compute_keypair_v2" "create_key_pair" {
  count      = var.create_key_pair_name != null ? 1 : 0
  name       = "${var.create_key_pair_name}_${random_string.random_string.result}"
  public_key = local.public_key
}

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
    volume_size           = local.boot_volume_size_in_gbs
    volume_type           = "General SSD"
    delete_on_termination = true
  }
  user_data = var.user_data_file_path != null ? fileexists(var.user_data_file_path) != false ? base64encode(file(var.user_data_file_path)) : null : var.user_data != null ? base64encode(var.user_data) : null
}
