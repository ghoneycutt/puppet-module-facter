# Class facter::fact
#
# Manage txt based external facts.
#
define facter::fact (
  $value,
  $fact      = $name,
  $file      = 'facts.txt',
  $facts_dir = '/etc/facter/facts.d',
) {

  include ::facter

  $match = "^${name}=\\S.*$"

  if $file != $facter::facts_file {
    file { "facts_file_${name}":
      ensure => file,
      path   => "${facts_dir}/${file}",
      owner  => $facter::facts_file_owner,
      group  => $facter::facts_file_group,
      mode   => $facter::facts_file_mode,
    }
  }

  file_line { "fact_line_${name}":
    path  => "${facts_dir}/${file}",
    line  => "${name}=${value}",
    match => $match,
  }
}
