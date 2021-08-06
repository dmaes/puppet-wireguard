# wireguard
class wireguard (
  # lint:ignore:parameter_order
  Hash $interfaces = {},
  Hash $interface_defaults,
  Boolean $manage_package = true,
  Boolean $debian_backports,
  Hash $debian_backports_repo = {}, # Custom options diverging from apt::backports
  # lint:endignore
) {

  include wireguard::install

  $_interface_defaults = merge($interface_defaults, { require => Class['wireguard::install'] })
  create_resources( 'wireguard::interface', $interfaces, $_interface_defaults )

}
