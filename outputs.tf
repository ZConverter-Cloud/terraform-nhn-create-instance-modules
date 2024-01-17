# locals {
#   result = tomap({
#     "result" : {
#       "Instance_information" : {
#         "instance_id" : openstack_compute_instance_v2.nhn_create_instance.id,
#         "availability_zone" : openstack_compute_instance_v2.nhn_create_instance.availability_zone,
#         "display_name" : openstack_compute_instance_v2.nhn_create_instance.name,
#         "ip" : {
#           "public_ip" : openstack_compute_floatingip_associate_v2.fip_associate.floating_ip,
#           "private_ip" : openstack_compute_instance_v2.nhn_create_instance.access_ip_v4
#         }
#       },
#       "Volume_Information" : openstack_compute_volume_attach_v2.attach_volume
#       "Security_Group" : openstack_networking_secgroup_rule_v2.secgroup_rule_1
#     }
#   })
# }

# output "result" {
#     value = local.result
# }

output "result" {
  value = {
    IP = openstack_compute_floatingip_associate_v2.fip_associate.floating_ip,
    OS = "${var.OS}-${var.OS_version}",
    VM_NAME = var.vm_name
  }
}
