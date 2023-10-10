output "startup_script" {
  value = templatefile("${path.module}/templates/wireguard-server-init.sh.tpl", {
    network_cidr       = var.network_cidr
    server_port        = var.server_port
    server_private_key = var.server_private_key
    server_public_key  = var.server_public_key
    clients            = var.clients
  })
  description = "Wireguard server virtual-machine/instance init scrypt to create all needed configs for server"
}

output "client_configs" {
  value = { for client in var.clients : client.name => templatefile("${path.module}/templates/wireguard-client.conf.tpl", {
    client_private_key = client.private_key
    client_ip          = client.ip
    route_ip_ranges    = client.route_ip_ranges
    dns                = var.dns
    server_public_ip   = var.server_public_ip
    server_port        = var.server_port
    server_public_key  = var.server_public_key
    keep_alive         = var.keep_alive
  }) }
  description = "Wireguard clients configs to copy/set in their laptops/machines /etc/wireguard/wg0.conf file"
}
