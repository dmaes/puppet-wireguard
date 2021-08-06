# wireguard::interface::peer
define wireguard::interface::peer (
  String $interface,
  String $public_key,
  Optional[String] $preshared_key = undef,
  Array[Stdlib::IP::Address] $allowed_ips = ['0.0.0.0/0', '::/0'],
  Optional[String] $endpoint = undef,
  Optional[Integer] $persistent_keepalive = undef,
) {

  concat::fragment{ "wg-${interface}-peer-${name}":
    target  => "/etc/wireguard/${interface}.conf",
    content => template('wireguard/interface-peer.erb'),
    order   => '10',
  }

}
