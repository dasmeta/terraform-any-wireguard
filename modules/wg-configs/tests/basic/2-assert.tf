resource "test_assertions" "dummy" {
  component = "this"

  equal "startup_scrypt" {
    description = "has output startup_scrypt correct?"
    got         = module.this.startup_script
    want        = <<EOT
#!/bin/bash -v

echo "Wireguard setup started!" > /note.txt

# install wireguard and neded tools
apt update && apt -y install net-tools wireguard

# create wireguard server configuration file
mkdir -p /etc/wireguard
cat > /etc/wireguard/wg0.conf <<- EOF
[Interface]
Address = 10.11.11.0/24
ListenPort = 51820
PrivateKey = CEXfZgx+G/rzVOawGWaMhFYKkMeTqI0BSr99Shbeb28=
PostUp = sysctl -w -q net.ipv4.ip_forward=1
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ENI -j MASQUERADE
PostDown = sysctl -w -q net.ipv4.ip_forward=0
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ENI -j MASQUERADE


[Peer]
# client1
PublicKey = lJd5CessDQ9eay8sUEA15/rNl+6eNcbaTT/jnQ2qhig=
AllowedIPs = 10.11.11.1/32

EOF

# Make sure we replace the "ENI" placeholder with the actual network interface name
export ENI=$(ip route get 8.8.8.8 | grep 8.8.8.8 | awk '{print $5}')
sed -i "s/ENI/$ENI/g" /etc/wireguard/wg0.conf

# Launch the WireGuard server
wg-quick up wg0
systemctl enable wg-quick@wg0
echo "Wireguard setup finished!" >> /note.txt
EOT
  }

  equal "client_configs" {
    description = "has output client_configs correct?"
    got         = module.this.client_configs
    want = {
      "client1" = <<-EOT
[Interface]
PrivateKey = eDWDX79XqXxK0nHwuvxq/yrp0tntk5ASKW8FeRTgBnQ=
DNS = 8.8.8.8

Address = 10.11.11.1/32

[Peer]
Endpoint = 1.2.3.4:51820
PublicKey = 6sPQH8RvnPmS8vGUpF050/S+PZu4yYQFowF1WAga7xg=
PersistentKeepalive = 25
AllowedIPs = 0.0.0.0/0

EOT
    }
  }
}
