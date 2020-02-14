# == Class: facter
#
# Manage facter
#
class facter (
  Boolean $manage_facts_d_dir = true,
  Boolean $purge_facts_d = false,
  Stdlib::Absolutepath $facts_d_dir = '/etc/facter/facts.d',
  String[1] $facts_d_owner = 'root',
  String[1] $facts_d_group = 'root',
  Optional[Stdlib::Filemode] $facts_d_mode = '0755',
  Stdlib::Absolutepath $path_to_facter = '/opt/puppetlabs/bin/facter',
  Stdlib::Absolutepath $path_to_facter_symlink = '/usr/local/bin/facter',
  Boolean $ensure_facter_symlink = false,
  Hash $facts_hash = {},
  Boolean $facts_hash_hiera_merge = false,
  String[1] $facts_file = 'facts.txt',
  String[1] $facts_file_owner = 'root',
  String[1] $facts_file_group = 'root',
  Optional[Stdlib::Filemode] $facts_file_mode = '0644',
) {
  if $facts['os']['family'] == 'windows' {
    $facts_file_path  = "${facts_d_dir}\\${facts_file}"
  } else {
    $facts_file_path  = "${facts_d_dir}/${facts_file}"
  }

  if $manage_facts_d_dir == true {
    if $facts['os']['family'] == 'windows' {
      exec { "mkdir_p-${facts_d_dir}":
        command => "cmd /c mkdir ${facts_d_dir}",
        creates => $facts_d_dir,
        path    => $::path,
      }
    } else {
      exec { "mkdir_p-${facts_d_dir}":
        command => "mkdir -p ${facts_d_dir}",
        creates => $facts_d_dir,
        path    => '/bin:/usr/bin',
      }
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
    path   => $facts_file_path,
    owner  => $facts_file_owner,
    group  => $facts_file_group,
    mode   => $facts_file_mode,
  }

  # optionally push fact to client
  if $facts_hash_hiera_merge == true {
    $facts_hash_real = lookup('facter::facts_hash', Hash, 'hash', {})
  } else {
    $facts_hash_real = $facts_hash
  }

  if ! empty($facts_hash_real) {
    $facts_defaults = {
      'file'      => $facts_file,
      'facts_dir' => $facts_d_dir,
    }
    create_resources('facter::fact', $facts_hash_real, $facts_defaults)
  }
}
