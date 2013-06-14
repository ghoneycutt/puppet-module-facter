# == Class: facter
#
# Defines the facter class which ensures that the package facter is installed.
# It also creates the dependant directories for facter /etc/facter/facts.d

class facter {

  Package {
    name      => 'facter',
    provider  => undef,
  }

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }



  package { "facter":
   ensure           => installed,
  }

  file { '/etc/facter':
    ensure  => directory,
    require => Package['facter'],
  }

  file { '/etc/facter/facts.d':
    ensure  => directory,
    require => Package['facter'],
  }
}
