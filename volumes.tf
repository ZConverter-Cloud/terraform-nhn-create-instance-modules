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