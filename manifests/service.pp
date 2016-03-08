class nrpe::service (
  $service_name    = $nrpe::service_name,
  $service_ensure  = $nrpe::service_ensure,
  $service_enabled = $nrpe::service_enabled,
  $if_noop         = $nrpe::if_noop,
) {

  service { $service_name:
    ensure => $service_ensure,
    enable => $service_enabled,
    noop   => $if_noop,
  }

}
