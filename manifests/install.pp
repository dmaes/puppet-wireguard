# wireguard::install
class wireguard::install (
  Boolean $manage_package = $::wireguard::manage_package,
  Boolean $debian_backports = $::wireguard::debian_backports,
  Hash $debian_backports_repo = $::wireguard::debian_backports_repo,
) {

  if $debian_backports {
    ensure_resource('class', 'apt::backports', $debian_backports_repo)
  }

  if $manage_package {
    ensure_packages(['wireguard'])
  }

  file{ '/etc/wireguard':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

}
