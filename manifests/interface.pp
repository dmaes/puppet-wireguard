# wireguard::interface
define wireguard::interface (
  Enum['present', 'absent'] $ensure = 'present',
  String $private_key,
  Stdlib::Port $listen_port = 51820,
  Optional[String] $fw_mark = undef,
  Hash $peers = {},
  Hash $peer_defaults = {},
  Enum['ifupd', 'wg-quick', 'none'] $method,
  String $interface = $name, # ifupd
  Optional[Stdlib::IP::Address::V4] $address4 = undef, # ifupd
  Optional[Stdlib::IP::Address::V6] $address6 = undef, # ifupd
  Optional[Stdlib::IP::Address::V4::Nosubnet] $gateway4 = undef, # ifupd
  Optional[Stdlib::IP::Address::V6::Nosubnet] $gateway6 = undef, # ifupd
  Array[Stdlib::IP::Address] $addresses = [], # wg-quick
  Array[Stdlib::IP::Address] $dns = [], # ifupd,wg-quick
  Optional[Integer] $mtu = undef, # ifupd,wg-quick
  Optional[String] $table = undef, # wg-quick
  Array[String] $pre_up = [], # ifupd,wg-quick
  Array[String] $post_up = [], # ifupd,wg-quick
  Array[String] $pre_down = [], # ifupd,wg-quick
  Array[String] $post_down = [], # ifupd,wg-quick
  Boolean $save_config = false, # wg-quick
  Hash $ifupd_opts4 = {}, # ifupd
  Hash $ifupd_opts6 = {}, # ifupd
) {

  concat{ "/etc/wireguard/${name}.conf":
    ensure => $ensure,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  concat::fragment{ "${name}-interface":
    target  => "/etc/wireguard/${name}.conf",
    content => template('wireguard/interface.erb'),
    order   => '00',
  }

  $_peer_defaults = {
    interface => $name,
  }
  $_actual_peer_defaults = merge($peer_defaults, $_peer_defaults)
  create_resources('wireguard::interface::peer', $peers, $_actual_peer_defaults)

  if $method == 'wg-quick' {

    if $address4 { warning( '$address4 is ifupd only, will be ignored for wg-quick, use $addresses instead' ) }
    if $address6 { warning( '$address6 is ifupd only, will be ignored for wg-quick, use $addresses instead' ) }
    if $gateway4 { warning( '$gateway4 is ifupd only, will be ignored' ) }
    if $gateway6 { warning( '$gateway6 is ifupd only, will be ignored' ) }
    if $ifupd_opts4.length > 0 { warning( '$ifupd_opts4 is ifupd only, will be ignored' ) }
    if $ifupd_opts6.length > 0 { warning( '$ifupd_opts6 is ifupd only, will be ignored' ) }

    $_service_ensure = $ensure ? {
      'present' => 'running',
      'absent'  => 'stopped',
    }

    $_service_enable = $ensure ? {
      'present' => true,
      'absent'  => false,
    }

    service{ "wg-quick@${name}.service":
      ensure    => $_service_ensure,
      provider  => 'systemd',
      enable    => $_service_enable,
      subscribe => Concat["/etc/wireguard/${name}.conf"],
    }

  } elsif $method == 'ifupd' {

    if $addresses.length > 0 { warning( '$addresses is wg-quick only, will be ignored for ifupd, use $address4 and/or $address6 instead' ) }
    if $table { warning( '$table is wg-quick only, will be ignored for ifupd' ) }
    if $save_config { warning( '$save_config is wg-quick only, will be ignored for ifupd' ) }

    $_pre_up = [
      "ip link add dev ${interface} type wireguard",
      "wg setconf ${interface} /etc/wireguard/${name}.conf",
    ]

    $_post_down = [
      "ip link del ${interface}",
    ]

    if $dns.length > 0 {
      $_dns_nameservers = join($dns, ' ')
    } else {
      $_dns_nameservers = undef
    }

    if $address4 {
      network::interface{ "${name}-${interface}-v4":
        ensure          => $ensure,
        interface       => $interface,
        ipaddress       => $address4,
        gateway         => $gateway4,
        mtu             => $mtu,
        method          => 'static',
        family          => 'inet',
        dns_nameservers => $_dns_nameservers,
        pre_up          => flatten($_pre_up, $pre_up),
        post_up         => $post_up,
        pre_down        => $pre_down,
        post_down       => flatten($_post_down, $post_down),
        require         => Concat["/etc/wireguard/${name}.conf"],
        *               => $ifupd_opts4
      }
    }
    if $address6 {
      network::interface{ "${name}-${interface}-v6":
        ensure          => $ensure,
        interface       => $interface,
        ipaddress       => $address6,
        gateway         => $gateway6,
        mtu             => $mtu,
        method          => 'static',
        family          => 'inet6',
        dns_nameservers => $_dns_nameservers,
        pre_up          => flatten($_pre_up, $pre_up),
        post_up         => $post_up,
        pre_down        => $pre_down,
        post_down       => flatten($_post_down, $post_down),
        require         => Concat["/etc/wireguard/${name}.conf"],
        *               => $ifupd_opts6
      }
    }

  }

}
