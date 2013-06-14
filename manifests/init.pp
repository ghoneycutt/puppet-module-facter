# == Class: facter
#
# Defines the facter class which ensures that the package facter is installed.
# It also creates the dependant folders for facter /etc/facter/facts.d

class facter {

  package_name = 'facter',
  package_provider = undef,
  
  dir_owner = 'root',
  dir_group = 'root',
  dir_mode = '0644',



  package { 'facter':
    ensure           => installed,
    package_name     => $package_name,
    package_provider => $package_provider,
  }
 
  file { '/etc/facter':
    ensure => directory,
    owner => $dir_owner,
    group => $dir_group,
    mode => $dir_mode,
    require => Package['facter'],
  }
 
  file { '/etc/facter/facts.d':
    ensure  => directory,
    owner => $dir_owner,
    group => $dir_group,
    mode => $dir_mode,
    require => Package['facter'],
  }
}
