# == Class: facter
#
# Manage facter
#
class facter (
  Boolean $manage_facts_d_dir                   = true,
  Boolean $purge_facts_d                        = false,
  Stdlib::Absolutepath $facts_d_dir             = '/etc/facter/facts.d',
  String $facts_d_owner                         = 'root',
  String $facts_d_group                         = 'root',
  Stdlib::Filemode $facts_d_mode                = '0755',
  Stdlib::Absolutepath $path_to_facter          = '/opt/puppetlabs/bin/facter',
  Stdlib::Absolutepath $path_to_facter_symlink  = '/usr/local/bin/facter',
  Boolean $ensure_facter_symlink                = false,
  Hash $facts_hash                              = {},
  Boolean $facts_hash_hiera_merge               = false,
  String $facts_file                            = 'facts.txt',
  String $facts_file_owner                      = 'root',
  String $facts_file_group                      = 'root',
  Stdlib::Filemode $facts_file_mode             = '0644',
  Stdlib::Absolutepath $facter_conf_dir         = '/etc/puppetlabs/facter',
  String $facter_conf_dir_owner                 = 'root',
  String $facter_conf_dir_group                 = 'root',
  Stdlib::Filemode $facter_conf_dir_mode        = '0755',
  String $facter_conf_name                      = 'facter.conf',
  String $facter_conf_owner                     = 'root',
  String $facter_conf_group                     = 'root',
  Stdlib::Filemode $facter_conf_mode            = '0644',
  Facter::Conf $facter_conf                     = {},
) {

  if $manage_facts_d_dir == true {
    exec { "mkdir_p-${facts_d_dir}":
      command => "mkdir -p ${facts_d_dir}",
      unless  => "test -d ${facts_d_dir}",
      path    => '/bin:/usr/bin',
    }

    file { 'facts_d_directory':
      ensure  => 'directory',
      path    => $facts_d_dir,
      owner   => $facts_d_owner,
      group   => $facts_d_group,
      mode    => $facts_d_mode,
      purge   => $purge_facts_d,
      recurse => $purge_facts_d,
      require => Exec["mkdir_p-${facts_d_dir}"],
    }
  }

  # optionally create symlinks to facter binary
  if $ensure_facter_symlink == true {
    file { 'facter_symlink':
      ensure => 'link',
      path   => $path_to_facter_symlink,
      target => $path_to_facter,
    }
  }

  file { 'facts_file':
    ensure => file,
    path   => "${facts_d_dir}/${facts_file}",
    owner  => $facts_file_owner,
    group  => $facts_file_group,
    mode   => $facts_file_mode,
  }

  if $facts_hash_hiera_merge == true {
    $facts_hash_real = hiera_hash('facter::facts_hash', {})
  } else {
    $facts_hash_real = $facts_hash
  }

  if ! empty( $facts_hash_real ) {
    $facts_defaults = {
      'file'      => $facts_file,
      'facts_dir' => $facts_d_dir,
    }
    create_resources('facter::fact',$facts_hash_real, $facts_defaults)
  }

  exec { "mkdir_p-${facter_conf_dir}":
    command => "mkdir -p ${facter_conf_dir}",
    unless  => "test -d ${facter_conf_dir}",
    path    => '/bin:/usr/bin',
  }
  file { $facter_conf_dir:
    ensure  => 'directory',
    owner   => $facter_conf_dir_owner,
    group   => $facter_conf_dir_group,
    mode    => $facter_conf_dir_mode,
    require => Exec["mkdir_p-${facter_conf_dir}"],
  }

  if ! empty($facter_conf) {
    # Template uses:
    # - $facter_conf
    file { "${facter_conf_dir}/${facter_conf_name}":
      ensure  => 'file',
      owner   => $facter_conf_owner,
      group   => $facter_conf_group,
      mode    => $facter_conf_mode,
      content => template('facter/facter.conf.erb'),
    }
  }

}
