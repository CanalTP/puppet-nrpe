class nrpe::config (
  $config_nrpe_user     = $nrpe::config_nrpe_user,
  $config_nrpe_group    = $nrpe::config_nrpe_group,
  $config_allowed_hosts = $nrpe::config_allowed_hosts,
  $config_include_dir   = $nrpe::config_include_dir,
  $config_plugins_dir   = $nrpe::config_plugins_dir,
  $if_noop              = $nrpe::if_noop,
) {

  File {
    noop => $if_noop,
  }

  file { '/etc/nagios/nrpe.cfg':
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nrpe/nrpe.cfg.erb'),
  }

  file { "${config_include_dir}/check_common.cfg":
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('nrpe/check_common.cfg.erb'),
  }

  file { 'NRPE plugins deployment':
    path    => $config_plugins_dir,
    source  => 'puppet:///modules/nrpe/plugins',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse =>  true,
  }

}
