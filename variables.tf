terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.48.0"
    }
  }
}

locals {
  public_key       = var.ssh_public_key != null ? var.ssh_public_key : var.ssh_public_key_file != null ? file(var.ssh_public_key_file) : tls_private_key.key[0].public_key_openssh
  destination_type = (split(".", var.flavor_name)[0]) == "u2" ? "local" : "volume"
  security_groups  = var.security_groups_name != null && var.create_security_group_name != null ? compact(concat([var.security_groups_name], [var.create_security_group_name])) : var.security_groups_name != null ? var.security_groups_name : var.create_security_group_name != null ? [var.create_security_group_name] : ["default"]
  boot_size        = local.destination_type == "local" ? (var.boot_size < 20 ? 20 : var.boot_size > 100 ? 100 : var.boot_size) : (var.boot_size < 20 ? 20 : var.boot_size > 2000 ? 2000 : var.boot_size)

  regex_list = {
    "windows" : "^Windows ${var.OS_version} STD \\(([\\.0-9]+)\\) EN$"
    "rocky" : "^Rocky Linux ${var.OS_version} \\(([\\.0-9]+)\\)$",
    "ubuntu server" : "^Ubuntu Server (${var.OS_version}[\\.0-9]+) LTS \\(([\\.0-9]+)\\)$",
    "centos" : "^CentOS ${var.OS_version} \\(([\\.0-9]+)\\)$",
    "debian buster" : "^Debian ${var.OS_version} Buster \\(([\\.0-9]+)\\)$",
    "debian bullseye" : "^Debian ${var.OS_version} Bullseye \\(([\\.0-9]+)\\)$"
  }
}

variable "region" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "OS" {
  type = string
}

variable "OS_version" {
  type = string
}

variable "boot_size" {
  type    = number
  default = 20
}

variable "flavor_name" {
  type = string
}

variable "key_pair_name" {
  type    = string
  default = null
}

variable "create_key_pair_name" {
  type    = string
  default = null
}

variable "ssh_public_key" {
  type    = string
  default = null
}

variable "ssh_public_key_file" {
  type    = string
  default = null
}

variable "network_name" {
  type = string
}

variable "security_groups_name" {
  type    = list(string)
  default = null
}

variable "create_security_group_name" {
  type    = string
  default = null
}

# variable "security_group_rules" {
#   type = optional(list(object({
#     direction = string
#     ethertype = string
#     protocol = string
#     port_range_min = string
#     port_range_max = string
#     remote_ip_prefix = string
#     direction = string
#   })))
# }

variable "user_data_file_path" {
  type = string
}

variable "additional_volumes" {
  type = list(number)
}