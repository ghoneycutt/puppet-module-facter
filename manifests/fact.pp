# Class facter::fact
#
# Manage txt based external facts.
#
define facter::fact (
  $value,
  $fact      = $name,
  $facts_dir = '/etc/facter/facts.d',
) {

  include 'facter'

  $match = "^${name}=\\S*$"

  file { "facts_file_${name}":
    ensure  => file,
    path    => "${facts_dir}/${name}.txt",
    owner   => $facter::facts_file_owner,
    group   => $facter::facts_file_group,
    mode    => $facter::facts_file_mode,
    require => File['facts_d_directory'],
  }

  file_line { "fact_line_${name}":
    path  => "${facts_dir}/${name}.txt",
    line  => "${name}=${value}",
    match => $match,
  }
}
