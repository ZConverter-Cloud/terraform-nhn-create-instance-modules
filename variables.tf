terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "1.48.0"
    }
  }
}

locals {
  public_key       = var.ssh_public_key != null ? var.ssh_public_key : var.ssh_public_key_file != null ? file(var.ssh_public_key_file) : null
  destination_type = (split(".", var.flavor_name)[0]) == "u2" ? "local" : "volume"
  security_groups  = var.security_group_name != null ? flatten(formatlist(var.security_group_name)) : var.create_security_group_name != null ? flatten(formatlist(openstack_networking_secgroup_v2.create_security_group[0].name)) : null
  boot_volume_size_in_gbs        = local.destination_type == "local" ? (var.boot_volume_size_in_gbs < 20 ? 20 : var.boot_volume_size_in_gbs > 100 ? 100 : var.boot_volume_size_in_gbs) : (var.boot_volume_size_in_gbs < 20 ? 20 : var.boot_volume_size_in_gbs > 2000 ? 2000 : var.boot_volume_size_in_gbs)

  regex_list = {
    "windows" : "^Windows ${var.OS_version == "2012" ? "2012 R2" : var.OS_version} STD \\(([\\.0-9]+)\\) EN$"
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

variable "boot_volume_size_in_gbs" {
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

variable "security_group_name" {
  type    = string
  default = null
}

variable "create_security_group_name" {
  type    = string
  default = null
}

variable "create_security_group_rules" {
  type = list(object({
    direction        = optional(string)
    ethertype        = optional(string)
    protocol         = optional(string)
    port_range_min   = optional(string)
    port_range_max   = optional(string)
    remote_ip_prefix = optional(string)
  }))
  default = null
}

variable "user_data" {
  type = string
  default = null
}

variable "user_data_file_path" {
  type = string
  default = null
}

variable "additional_volumes" {
  type = list(number)
}
