resource "tls_private_key" "key" {
  count     = var.create_key_pair_name != null && var.ssh_public_key == null && var.ssh_public_key_file == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = "2048"
}