output "public_ip" {
  value = aws_eip.this.public_ip
}

output "client_configs" {
  value = { for client in var.clients : client.name => templatefile("${path.module}/templates/wireguard-client.conf.tpl", {
    client_private_key = client.private_key
    client_ip          = client.ip
    route_ip_ranges    = client.route_ip_ranges
    dns                = var.dns
    server_public_ip   = aws_eip.this.public_ip
    server_port        = var.server_port
    server_public_key  = var.server_public_key
    keep_alive         = var.keep_alive
  }) }
  description = "The client configs to copy/set in their laptops/machines /etc/wireguard/wg0.conf file"
}

output "debug" {
  value = data.aws_subnets.public_subnets
}
