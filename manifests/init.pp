# == Class: facter
#

class facter {

  package { 'facter':
    ensure => installed,
  }
  
  file { '/etc/puppet/facter.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['facter'],
  }
}
