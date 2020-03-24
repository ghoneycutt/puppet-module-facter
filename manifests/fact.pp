# @summary Define txt based external facts
#
# @param value
#   Value of the fact.
#
# @param fact
#   Name of the fact
#
# @param file
#   File in which the fact will be placed. If not specified, use the default
#   facts file.
#
# @param facts_dir
#   Directory in which the file will be placed. If not specified, use the
#   default facts_d_dir.
#
define facter::fact (
  String[1] $value,
  String[1] $fact = $name,
  Optional[String[1]] $file = undef,
  Optional[Stdlib::Absolutepath] $facts_dir = undef,
) {

  include facter

  $facts_file = pick($file, $facter::facts_file)
  $facts_dir_path = pick($facts_dir, $facter::facts_d_dir)
  if $facts['os']['family'] == 'windows' {
    $facts_file_path = "${facts_dir_path}\\${facts_file}"
  } else {
    $facts_file_path = "${facts_dir_path}/${facts_file}"
  }

  $match = "^${name}=\\S.*$"

  if $facts_file != $facter::facts_file {
    if $facter::facts_file_purge {
      $concat_target = "facts_file_${name}"
      concat { "facts_file_${name}":
        ensure => 'present',
        path   => $facts_file_path,
        owner  => $facter::facts_file_owner,
        group  => $facter::facts_file_group,
        mode   => $facter::facts_file_mode,
      }
    } else {
      file { "facts_file_${name}":
        ensure => file,
        path   => $facts_file_path,
        owner  => $facter::facts_file_owner,
        group  => $facter::facts_file_group,
        mode   => $facter::facts_file_mode,
      }
    }
  } else {
    $concat_target = 'facts_file'
  }

  if $facter::facts_file_purge {
    concat::fragment { "fact_line_${name}":
      target  => $concat_target,
      content => "${name}=${value}",
    }
  } else {
    file_line { "fact_line_${name}":
      path  => $facts_file_path,
      line  => "${name}=${value}",
      match => $match,
    }
  }
}
