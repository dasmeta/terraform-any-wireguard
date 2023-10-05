# aws ec2 wireguard setup

The module allows to create/configure wireguard VPN server and clients. To install wireguard check here: https://www.wireguard.com/install/

Examples can found in [tests](tests) folder,


NOTES:

1.  server and client public/private keys generation (please generate separate public/private key pairs for server and each client)

  a. for linux and cli use wg cli tool:
  ```sh
  # for server key fi
  wg genkey > privatekey-server
  wg pubkey < privatekey-server > publickey-server

  wg genkey > privatekey-client1
  wg pubkey < privatekey-client1 > publickey-client1
  ```
  you need only key values to pass to module so that you can remove generated private/public keys as soon as you copy keys to module params

  b. for macOS and windows you can also use gui, check GUI app corresponding docs

2. get and usa clients configs

There is module output named client_config and it contains each client wireguard config file which needs to be set in clients laptop/machine

  a. for linux cli: `/etc/wireguard/wg0.conf` path(the filename can be custom, but should be with extension .conf) if you use wg-quick cli, create this path and file if not exist, the file should be owned by root and you will probably need to switch to root (sudo su). in order to start/stop connection switch to root user and run `wg-quick up wg0` and `wg-quick down wg0`

  b. for mac os and windows gui: you can import it from wireguard program GUI, there should be option to set name and start/stop connection
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.16 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.16 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_eip_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip_association) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.wireguard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_subnets.public_subnets](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clients"></a> [clients](#input\_clients) | Wireguard clients/peers list with configs | <pre>list(object({<br>    name            = string                                   # should be unique in list<br>    ip              = string                                   # client uniq IP form var.network_cidr range in cidr format, TODO: we maybe can automate this IP creation inside module<br>    route_ip_ranges = string                                   # comma separated IP ranges that the client should route via the VPN in format "1.2.3.4/32,1.1.1.1/16", set "0.0.0.0/0" to route all traffic through VPN<br>    public_key      = string                                   # public key of client/peer, both private and public keys can be generated by using wg cli and client private key: `wg pubkey < privatekey-client1 > publickey-client1`, # TODO: we probably need to have this set as sensitive<br>    private_key     = optional(string, "{client-private-key}") # client private key, pass in case you want to get fully prepared to use client_configs output, can be generated using wg cli: `wg genkey > privatekey-client1`<br>  }))</pre> | `[]` | no |
| <a name="input_dns"></a> [dns](#input\_dns) | Custom DNS server | `string` | `null` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | The IPs/CIDRs from where the instance wireguard and ssh port are open to connect | `list(any)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The wireguard server machine instance type | `string` | `"t2.micro"` | no |
| <a name="input_keep_alive"></a> [keep\_alive](#input\_keep\_alive) | CLients peer connection persistance keep alive config | `number` | `25` | no |
| <a name="input_name"></a> [name](#input\_name) | The name to use of instance/machine | `string` | n/a | yes |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | Wireguard network CIDR which should not overlap with local/server networks | `string` | `"10.11.11.0/24"` | no |
| <a name="input_server_port"></a> [server\_port](#input\_server\_port) | Wireguard server port number | `number` | `51820` | no |
| <a name="input_server_private_key"></a> [server\_private\_key](#input\_server\_private\_key) | Wireguard server private key, which can be generated using wg cli tool: `wg genkey > privatekey-server` | `string` | n/a | yes |
| <a name="input_server_public_key"></a> [server\_public\_key](#input\_server\_public\_key) | Wireguard server public key, which can be generated using wg cli tool and server private key: `wg pubkey < privatekey-server > publickey-server` | `string` | n/a | yes |
| <a name="input_ssh_key_name"></a> [ssh\_key\_name](#input\_ssh\_key\_name) | The ssh key to attach to instances | `string` | `null` | no |
| <a name="input_ubuntu_version"></a> [ubuntu\_version](#input\_ubuntu\_version) | The version of ubuntu to use | `string` | `"ubuntu-focal-20.04"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The vpc id | `string` | n/a | yes |
| <a name="input_vpc_subnet_additional_filter"></a> [vpc\_subnet\_additional\_filter](#input\_vpc\_subnet\_additional\_filter) | Additional filters to get subnet under vpc, where instance will be created | `list(any)` | <pre>[<br>  {<br>    "name": "map-public-ip-on-launch",<br>    "values": [<br>      true<br>    ]<br>  }<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_configs"></a> [client\_configs](#output\_client\_configs) | The client configs to copy/set in their laptops/machines /etc/wireguard/wg0.conf file |
| <a name="output_debug"></a> [debug](#output\_debug) | n/a |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->