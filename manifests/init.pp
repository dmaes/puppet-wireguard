# wireguard
class wireguard (
  # lint:ignore:parameter_order
  Hash $interfaces = {},
  Hash $interface_defaults,
  Boolean $manage_package = true,
  String $package_name,
  Boolean $debian_backports,
  Hash $debian_backports_repo = {}, # Custom options diverging from apt::backports
  Enum['syncconf', 'setconf'] $default_conf_update_cmd = 'syncconf', # see README for difference
  # lint:endignore
) {

  include wireguard::install

  $_interface_defaults = merge($interface_defaults, { require => Class['wireguard::install'] })
  create_resources( 'wireguard::interface', $interfaces, $_interface_defaults )

}
