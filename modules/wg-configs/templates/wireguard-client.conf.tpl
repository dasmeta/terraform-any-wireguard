[Interface]
PrivateKey = ${client_private_key}
%{ if dns != null ~}
DNS = ${dns}
%{ endif ~}

Address = ${client_ip}

[Peer]
Endpoint = ${server_public_ip}:${server_port}
PublicKey = ${server_public_key}
PersistentKeepalive = ${keep_alive}
AllowedIPs = ${route_ip_ranges}
