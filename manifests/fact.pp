# Class facter::fact
#
# Manage file based customized fact
#

define facter::fact (
  $file       = $facter::facts_file,
  $facts_dir  = $facter::facts_d_dir,
  $fact       = $name,
  $value      = undef,
  $match      = "^${name}=\\S*$",
) {

  if $file != $facter::facts_file {
    file { "facts_file_${name}":
      ensure  => file,
      path    => "${facts_dir}/${file}",
      owner   => $facter::facts_file_owner,
      group   => $facter::facts_file_group,
      mode    => $facter::facts_file_mode,
      require => File['facts_d_directory'],
    }
  }

  file_line { "fact_line_${name}":
    path  => "${facts_dir}/${file}",
    line  => "${name}=${value}",
    match => $match,
  }
}

