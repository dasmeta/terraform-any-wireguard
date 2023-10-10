#!/bin/bash -v

echo "Wireguard setup started!" > /note.txt

# install wireguard and neded tools
apt update && apt -y install net-tools wireguard

# create wireguard server configuration file
mkdir -p /etc/wireguard
cat > /etc/wireguard/wg0.conf <<- EOF
[Interface]
Address = ${network_cidr}
ListenPort = ${server_port}
PrivateKey = ${server_private_key}
PostUp = sysctl -w -q net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ENI -j MASQUERADE
PostDown = sysctl -w -q net.ipv4.ip_forward=0
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ENI -j MASQUERADE

%{ for client in clients }
[Peer]
# ${client.name}
PublicKey = ${client.public_key}
AllowedIPs = ${client.ip}
%{ endfor ~}

EOF

# Make sure we replace the "ENI" placeholder with the actual network interface name
export ENI=$(ip route get 8.8.8.8 | grep 8.8.8.8 | awk '{print $5}')
sed -i "s/ENI/$ENI/g" /etc/wireguard/wg0.conf

# Launch the WireGuard server
wg-quick up wg0
systemctl enable wg-quick@wg0
echo "Wireguard setup finished!" >> /note.txt
