# wireguard::interface::peer
define wireguard::interface::peer (
  String $interface,
  String $public_key,
  Optional[String] $preshared_key = undef,
  Array[Stdlib::IP::Address] $allowed_ips = ['0.0.0.0/0', '::/0'],
  Optional[String] $endpoint = undef,
  Optional[Integer] $persistent_keepalive = undef,
  Boolean $ifupd_auto_routes = false,
  String $ifupd_interface = $interface,
) {

  concat::fragment{ "wg-${interface}-peer-${name}":
    target  => "/etc/wireguard/${interface}.conf",
    content => template('wireguard/interface-peer.erb'),
    order   => '10',
  }

  if $ifupd_auto_routes {
    $allowed_ips.each |$ip| {
      $route = "${ip} dev ${ifupd_interface}"
      $test = "echo $(ip -4 r; ip -6 r) | grep -q '${route}'"
      concat::fragment{ "wg-${interface}-peer-${name}-route-${ip}":
        target  => "/etc/wireguard/${interface}-routes",
        content => "${test} || ip r add ${route}\n",
      }
    }
  }

}
