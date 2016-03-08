class nrpe (
  $package_name         = undef,
  $package_ensure       = installed,
  $service_name         = undef,
  $service_ensure       = running,
  $service_enabled      = true,
  $config_nrpe_user     = undef,
  $config_nrpe_group    = undef,
  $config_allowed_hosts = undef,
  $config_include_dir   = undef,
  $config_plugins_dir   = undef,
  $if_noop              = $::clientnoop,
) {

  class { '::nrpe::install': } ->
  class { '::nrpe::config': } ~>
  class { '::nrpe::service': } ->
  Class['nrpe']

}
