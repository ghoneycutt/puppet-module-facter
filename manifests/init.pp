# @summary Manage facter
#
# This class will manage facter and allow you to specify external facts.
#
# @param manage_facts_d_dir
#   Boolean to determine if the external facts directory will be managed.
#
# @param purge_facts_d
#   Boolean to determine if the external facts directory should be purged. This
#   will remove files not managed by Puppet.
#
# @param facts_d_dir
#   Path to the directory which will contain the external facts.
#
# @param facts_d_owner
#   The owner of the `facts_d_dir`.
#
# @param facts_d_group
#   The group of the `facts_d_dir`.
#
# @param facts_d_mode
#   The mode of the `facts_d_dir`.
#
# @param path_to_facter
#   The path to the facter binary.
#
# @param path_to_facter_symlink
#   Path to a symlink that points to the facter binary.
#
# @param ensure_facter_symlink
#   Boolean to determine if the symlink should be present.
#
# @param facts_hash
#   A hash of `facter::fact` entries.
#
# @param structured_data_facts_hash
#   A hash of `facter::structured_data_fact` entries.
#
# @param facts_file
#   The file in which the text based external facts are stored. This file must
#   end with '.txt'.
#
# @param facts_file_owner
#   The owner of the facts_file.
#
# @param facts_file_group
#   The group of the facts_file.
#
# @param facts_file_mode
#   The mode of the facts_file.
#
# @param facter_conf_dir
#   The facter configuration directory
#
# @param facter_conf_dir_owner
#   The facter configuration directory owner
#
# @param facter_conf_dir_group
#   The facter configuration directory group owner
#
# @param facter_conf_dir_mode
#   The facter configuration directory mode
#
# @param facter_conf_name
#   The facter configuration file name
#
# @param facter_conf_owner
#   The facter configuration file name owner
#
# @param facter_conf_group
#   The facter configuration file name group owner
#
# @param facter_conf_mode
#   The facter configuration file name mode
#
# @param facter_conf
#   Hash of facter configurations
#
class facter (
  Boolean $manage_facts_d_dir = true,
  Boolean $purge_facts_d = false,
  Stdlib::Absolutepath $facts_d_dir = '/etc/facter/facts.d',
  String[1] $facts_d_owner = 'root',
  String[1] $facts_d_group = 'root',
  Stdlib::Filemode $facts_d_mode = '0755',
  Stdlib::Absolutepath $path_to_facter = '/opt/puppetlabs/bin/facter',
  Stdlib::Absolutepath $path_to_facter_symlink = '/usr/local/bin/facter',
  Boolean $ensure_facter_symlink = false,
  Hash $facts_hash = {},
  Hash $structured_data_facts_hash = {},
  Pattern[/\.txt*\Z/] $facts_file = 'facts.txt',
  String[1] $facts_file_owner = 'root',
  String[1] $facts_file_group = 'root',
  Stdlib::Filemode $facts_file_mode = '0644',
  Stdlib::Absolutepath $facter_conf_dir = '/etc/puppetlabs/facter',
  String[1] $facter_conf_dir_owner = 'root',
  String[1] $facter_conf_dir_group = 'root',
  Stdlib::Filemode $facter_conf_dir_mode = '0755',
  String[1] $facter_conf_name = 'facter.conf',
  String[1] $facter_conf_owner = 'root',
  String[1] $facter_conf_group = 'root',
  Stdlib::Filemode $facter_conf_mode = '0644',
  Facter::Conf $facter_conf = {},
) {
  if $facts['os']['family'] == 'windows' {
    $facts_file_path  = "${facts_d_dir}\\${facts_file}"
    $facts_d_mode_real = undef
    # Have to allow mode to be set as undef to concat will
    # default to '0644' which could cause issues
    $facts_file_mode_real = $facts_file_mode
    $facter_conf_dir_mode_real = undef
    $facter_conf_mode_real = undef
  } else {
    $facts_file_path  = "${facts_d_dir}/${facts_file}"
    $facts_d_mode_real = $facts_d_mode
    $facts_file_mode_real = $facts_file_mode
    $facter_conf_dir_mode_real = $facter_conf_dir_mode
    $facter_conf_mode_real = $facter_conf_mode
  }

  if $manage_facts_d_dir == true {
    if $facts['os']['family'] == 'windows' {
      exec { "mkdir_p-${facts_d_dir}":
        command => "cmd /c mkdir ${facts_d_dir}",
        creates => $facts_d_dir,
        path    => $facts['path'],
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
      mode    => $facts_d_mode_real,
      purge   => $purge_facts_d,
      recurse => $purge_facts_d,
      require => Exec["mkdir_p-${facts_d_dir}"],
      before  => Concat['facts_file'],
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

  concat { 'facts_file':
    ensure         => 'present',
    path           => $facts_file_path,
    owner          => $facts_file_owner,
    group          => $facts_file_group,
    mode           => $facts_file_mode_real,
    ensure_newline => true,
  }
  # One fragment must exist in order for contents to be managed
  concat::fragment { 'facts_file-header':
    target  => 'facts_file',
    content => "# File managed by Puppet\n#DO NOT EDIT",
    order   => '00',
  }

  $facts_defaults = {
    'file'      => $facts_file,
    'facts_dir' => $facts_d_dir,
  }

  $facts_hash.each |$k, $v| {
    facter::fact { $k:
      * => $v,
    }
  }

  $structured_data_facts_hash.each |$k, $v| {
    facter::structured_data_fact { $k:
      * => $v,
    }
  }

  if $facts['os']['family'] == 'windows' {
    exec { "mkdir_p-${facter_conf_dir}":
      command => "cmd /c mkdir ${facter_conf_dir}",
      creates => $facter_conf_dir,
      path    => $facts['path'],
    }
  } else {
    exec { "mkdir_p-${facter_conf_dir}":
      command => "mkdir -p ${facter_conf_dir}",
      creates => $facter_conf_dir,
      path    => '/bin:/usr/bin',
    }
  }
  file { $facter_conf_dir:
    ensure  => 'directory',
    owner   => $facter_conf_dir_owner,
    group   => $facter_conf_dir_group,
    mode    => $facter_conf_dir_mode_real,
    require => Exec["mkdir_p-${facter_conf_dir}"],
  }
  if ! empty($facter_conf) {
    $facter_conf_json = stdlib::to_json_pretty($facter_conf)
    file { "${facter_conf_dir}/${facter_conf_name}":
      ensure  => 'file',
      owner   => $facter_conf_owner,
      group   => $facter_conf_group,
      mode    => $facter_conf_mode_real,
      content => "# File managed by Puppet, do not edit\n${facter_conf_json}",
    }
  }
}
