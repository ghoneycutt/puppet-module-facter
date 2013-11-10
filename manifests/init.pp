# == Class: facter
#
# Manage facter
#
class facter (
  $package_name   = 'facter',
  $package_ensure = 'present',
  $facts_d_dir    = '/etc/facter/facts.d',
  $facts_d_owner  = 'root',
  $facts_d_group  = 'root',
  $facts_d_mode   = '0755',
) {

  validate_re($package_ensure,
    '^(present)|(absent)$',
    "facter::package_ensure must be \'present\' or \'absent\'. Detected value is <${package_ensure}>."
  )

  validate_absolute_path($facts_d_dir)

  validate_re($facts_d_mode,
    '^\d{4}$',
    "facter::facts_d_mode must be a four digit mode. Detected value is <755>."
  )

  package { 'facter':
    ensure => $package_ensure,
    name   => $package_name,
  }

  common::mkdir_p { $facts_d_dir: }

  file { 'facts_d_directory':
    ensure  => 'directory',
    path    => $facts_d_dir,
    owner   => $facts_d_owner,
    group   => $facts_d_group,
    mode    => $facts_d_mode,
    require => Common::Mkdir_p[$facts_d_dir],
  }
}
