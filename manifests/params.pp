class nrpe::params {

  if $::osfamily == 'RedHat' {

    packages = [ 'nrpe', 'nagios-plugins-all' ]
    config_nrpe_user = 'nrpe'
    config_nrpe_group = 'nrpe'
    config_include_dir = '/etc/nrpe.d'
    config_plugins_dir = '/usr/lib64/nagios/plugins'
    service_name = 'nrpe'

    if $::operatingsystemmajrelease == 6 {
    }
    elsif $::operatingsystemmajrelease == 7 {
    }
  }
  elsif $::osfamily == 'Debian' {

    packages = [ 'nagios-nrpe-server', 'nagios-plugins' ]
    config_nrpe_user = 'nagios'
    config_nrpe_group = 'nagios'
    config_include_dir = '/etc/nagios/nrpe.d'
    config_plugins_dir = '/usr/lib/nagios/plugins'
    service_name = 'nagios-nrpe-server'

    if $::operatingsystemmajrelease == 6 {
      config_plugins_dir = '/usr/lib64/nagios/plugins'
    }
    elsif $::operatingsystemmajrelease == 7 {
    }
    elsif $::operatingsystemmajrelease == 8 {
    }
  }

}
