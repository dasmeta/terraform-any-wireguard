output "public_ip" {
  value = aws_eip.this.public_ip
}

output "client_configs" {
  value       = module.wg_configs.client_configs
  description = "The client configs to copy/set in their laptops/machines /etc/wireguard/wg0.conf file"
}
