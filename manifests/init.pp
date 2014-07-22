# == Class: facter
#
# Manage facter
#
class facter (
  $manage_puppetlabs_repo = false,
  $manage_package         = true,
  $package_name           = 'facter',
  $package_ensure         = 'present',
  $manage_facts_d_dir     = true,
  $facts_d_dir            = '/etc/facter/facts.d',
  $facts_d_owner          = 'root',
  $facts_d_group          = 'root',
  $facts_d_mode           = '0755',
  $path_to_facter         = '/usr/bin/facter',
  $path_to_facter_symlink = '/usr/local/bin/facter',
  $ensure_facter_symlink  = false,
) {

  if type($manage_puppetlabs_repo) == 'string' {
    $manage_puppetlabs_repo_real = str2bool($manage_puppetlabs_repo)
  } else {
    validate_bool($manage_puppetlabs_repo)
    $manage_puppetlabs_repo_real = $manage_puppetlabs_repo
  }

  validate_absolute_path($facts_d_dir)

  validate_re($facts_d_mode,
    '^\d{4}$',
    "facter::facts_d_mode must be a four digit mode. Detected value is <${facts_d_mode}>."
  )

  # validate params
  validate_absolute_path($path_to_facter_symlink)
  validate_absolute_path($path_to_facter)

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

  if type($package_name) != 'String' and type($package_name) != 'Array' {
    fail('facter::package_name must be a string or an array.')
  }

  if $manage_puppetlabs_repo_real == true {
    case $::osfamily {
      'RedHat': {
        include puppetlabs_yum
        $package_require  = Yumrepo['puppetlabs-products']
      }
      default: {
        $package_require  = undef
      }
    }
  } else {
    $package_require  = undef
  }

  if $manage_package_real == true {

    package { $package_name:
      ensure  => $package_ensure,
      require => $package_require,
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

  if type($ensure_facter_symlink) == 'string' {
    $ensure_facter_symlink_bool = str2bool($ensure_facter_symlink)
  } else {
    $ensure_facter_symlink_bool = $ensure_facter_symlink
  }
  validate_bool($ensure_facter_symlink_bool)

  # optionally create symlinks to facter binary
  if $ensure_facter_symlink_bool == true {

    file { 'facter_symlink':
      ensure => 'link',
      path   => $path_to_facter_symlink,
      target => $path_to_facter,
    }
  }
}
