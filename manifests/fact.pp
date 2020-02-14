# Class facter::fact
#
# Manage txt based external facts.
#
define facter::fact (
  $value,
  String[1] $fact = $name,
  String[1] $file = 'facts.txt'
  Stdlib::Absolutepath $facts_dir = '/etc/facter/facts.d',
) {
  include facter

  $facts_file = pick($file, $facter::facts_file)
  $facts_dir_path = pick($facts_dir, $facter::facts_d_dir)
  if $facts['os']['family'] == 'windows' {
    $facts_file_path = "${facts_dir_path}\\${file}"
  } else {
    $facts_file_path = "${facts_dir_path}/${file}"
  }

  $match = "^${name}=\\S*$"

  if $file != $facter::facts_file {
    file { "facts_file_${name}":
      ensure => file,
      path   => $facts_file_path,
      owner  => $facter::facts_file_owner,
      group  => $facter::facts_file_group,
      mode   => $facter::facts_file_mode,
    }
  }

  file_line { "fact_line_${name}":
    path  => $facts_file_path,
    line  => "${name}=${value}",
    match => $match,
  }
}
