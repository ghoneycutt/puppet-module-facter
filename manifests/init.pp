# == Class: facter
#
# Manage facter
#
class facter (
  $manage_package     = true,
  $package_name       = 'facter',
  $package_ensure     = 'present',
  $manage_facts_d_dir = true,
  $facts_d_dir        = '/etc/facter/facts.d',
  $facts_d_owner      = 'root',
  $facts_d_group      = 'root',
  $facts_d_mode       = '0755',
) {

  validate_re($package_ensure,
    '^(present)|(absent)$',
    "facter::package_ensure must be \'present\' or \'absent\'. Detected value is <${package_ensure}>."
  )

  validate_absolute_path($facts_d_dir)

  validate_re($facts_d_mode,
    '^\d{4}$',
    "facter::facts_d_mode must be a four digit mode. Detected value is <${facts_d_mode}>."
  )

  if type($manage_package) == 'string' {
    $manage_package_real = str2bool($manage_package)
  } else {
    validate_bool($manage_package)
    $manage_package_real = $manage_package
  }

  if type($manage_facts_d_dir) == 'string' {
    $manage_facts_d_dir_real = str2bool($manage_facts_d_dir)
  } else {
    validate_bool($manage_facts_d_dir)
    $manage_facts_d_dir_real = $manage_facts_d_dir
  }

  if $manage_package_real == true {

    package { 'facter':
      ensure => $package_ensure,
      name   => $package_name,
    }
  }

  if $manage_facts_d_dir_real == true {

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
}
