class nrpe::install (
  $package_name   = $nrpe::package_name,
  $package_ensure = $nrpe::package_ensure,
  $if_noop        = $nrpe::brsnoop,
) {

  $defaults = {
    noop => $if_noop,
  }

  create_resources ( package, hiera('nrpe::packages'), $defaults )

}
