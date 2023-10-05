module "this" {
  source = "../../"

  name         = "wireguard-test-2"
  vpc_id       = "vpc-046effd7e14742653"
  ssh_key_name = "wireguard-test-2"

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
