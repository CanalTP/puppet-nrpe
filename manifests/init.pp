class nrpe (
  $package_name         = $::nrpe::params::package_name,
  $package_ensure       = installed,
  $config_nrpe_user     = $::nrpe::params::config_nrpe_user,
  $config_nrpe_group    = $::nrpe::params::config_nrpe_group,
  $config_allowed_hosts = [ 'ctp-prd-poller.canaltp.prod', 'ctp-prd-poller2.canaltp.prod', 'ctp-prd-poller3.canaltp.prod', 'par-vm03.srv.canaltp.fr', '10.2.0.250' ],
  $config_include_dir   = $::nrpe::params::config_include_dir,
  $config_plugins_dir   = $::nrpe::params::config_plugins_dir,
  $service_name         = $::nrpe::params::service_name,
  $service_ensure       = running,
  $service_enabled      = true,
  $if_noop              = $::clientnoop,
) inherits ::nrpe::params {

  class { '::nrpe::install': } ->
  class { '::nrpe::config': } ~>
  class { '::nrpe::service': } ->
  Class['nrpe']

}
