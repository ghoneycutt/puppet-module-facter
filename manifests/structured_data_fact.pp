# @summary Define YAML based external structured data facts.
#
# @param data
#   A hash of facts. All keys must be strings.
#
# @param file
#   File in which the fact will be placed. The file name must end with '.yaml'.
#
# @param facts_dir
#   Directory in which the file will be placed. If not specified, use the
#   default facts_d_dir.
#
define facter::structured_data_fact (
  Hash[String[1], Data] $data,
  Pattern[/\.yaml*\Z/] $file = 'facts.yaml',
  Optional[Stdlib::Absolutepath] $facts_dir = undef,
) {

  include facter

  $facts_dir_path = pick($facts_dir, $facter::facts_d_dir)
  if $facts['os']['family'] == 'windows' {
    $facts_file_path = "${facts_dir_path}\\${file}"
  } else {
    $facts_file_path = "${facts_dir_path}/${file}"
  }

  file { "structured_data_fact_${file}":
    ensure  => file,
    path    => $facts_file_path,
    content => template('facter/structured_data_fact.erb'),
    owner   => $facter::facts_file_owner,
    group   => $facter::facts_file_group,
    mode    => $facter::facts_file_mode,
  }
}
