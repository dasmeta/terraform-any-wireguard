# terraform-any-wireguard
create/configure wireguard on different linux machines including aws/gcp instances
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
# The module submodules allow to create/configure wireguard VPN server and get client configs.

The root module is empty, so that in order to create wireguard setup you need to use submodules
Right now we support two clouds aws and gcp, and module sources can be found in [modules](modules).
The cloud specific modules creates virtual machine instance in cloud for Wireguard server, sets firewall/security-group ingress rules, and assigns public static IP.

To install wireguard check here: https://www.wireguard.com/install/

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

a. for linux cli: `/etc/wireguard/wg0.conf` path(the filename can be custom, but should be with extension .conf) if you use wg-quick cli, create this path and file if not exist, the file should be owned by root and you will probably need to switch to root (sudo su). in order to start/stop connection switch to root user and run `wg-quick up wg0` and `wg-quick down wg0`.
b. for macos and windows gui: you can import it from wireguard program GUI, there should be option to set name and start/stop connection.
d. on all linux/macos/windows machines where wg-quick installed clients can also just save wireguard config file into a /some-path/file.conf and run it from cli using `wg-quick up /some-path/file.conf`. to stop just run `wg-quick down /some-path/file.conf`.

3. to test wireguard vpn clients setup
a. run `sudo wg` to see if there is wireguard vpn setup up and see how much traffic go through it
b. run `route -n` to see if local routes have been set correctly when you up a wireguard client
c. you can set route_ip_ranges = "34.160.111.145/32" for client and use `curl ifconfig.me` to see if your public IP getting changed to cloud static IP
d. to enable and check local wireguard logs look this gist: https://gist.github.com/artizirk/5bc87e345f850a8a0724929e0436ef84

## Example for aws setup

```hcl
module "this" {
  source = "../../" # check/set terraform registry value before using this in your setups: https://registry.terraform.io/modules/dasmeta/wireguard/any/latest/submodules/aws

  name   = "wireguard-test-2"
  vpc_id = "vpc-046effd7e14742653"

  server_private_key = "CEXfZgx+G/rzVOawGWaMhFYKkMeTqI0BSr99Shbeb28="
  server_public_key  = "6sPQH8RvnPmS8vGUpF050/S+PZu4yYQFowF1WAga7xg="

  clients = [
    {
      name            = "client1"
      public_key      = "lJd5CessDQ9eay8sUEA15/rNl+6eNcbaTT/jnQ2qhig="
      private_key     = "eDWDX79XqXxK0nHwuvxq/yrp0tntk5ASKW8FeRTgBnQ="
      ip              = "10.11.11.1/32"
      route_ip_ranges = "34.160.111.145/32" # this is ifconfig.me website/service ip with show requester IP, check things after apply by using command `curl ifconfig.me`
    }
  ]
}
```

## Example for gcp setup

```hcl
module "this" {
  source = "../../" # check/set terraform registry value before using this in your setups: https://registry.terraform.io/modules/dasmeta/wireguard/any/latest/submodules/gcp

  name     = "wireguard-test-2"
  vpc_name = "default"

  server_private_key = "CEXfZgx+G/rzVOawGWaMhFYKkMeTqI0BSr99Shbeb28="
  server_public_key  = "6sPQH8RvnPmS8vGUpF050/S+PZu4yYQFowF1WAga7xg="

  clients = [
    {
      name            = "client1"
      public_key      = "lJd5CessDQ9eay8sUEA15/rNl+6eNcbaTT/jnQ2qhig="
      private_key     = "eDWDX79XqXxK0nHwuvxq/yrp0tntk5ASKW8FeRTgBnQ="
      ip              = "10.11.11.1/32"
      route_ip_ranges = "34.160.111.145/32" # this is ifconfig.me website/service ip with show requester IP, check things after apply by using command `curl ifconfig.me`
    }
  ]
}
```
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
