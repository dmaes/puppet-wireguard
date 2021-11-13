# wireguard::install
class wireguard::install (
  Boolean $manage_package = $::wireguard::manage_package,
  String $package_name = $::wireguard::package_name,
  Boolean $debian_backports = $::wireguard::debian_backports,
  Hash $debian_backports_repo = $::wireguard::debian_backports_repo,
) {

  if $debian_backports {
    ensure_resource('class', 'apt::backports', $debian_backports_repo)
  }

  if $manage_package {
    ensure_packages([$package_name])
  }

  file{ '/etc/wireguard':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

}
