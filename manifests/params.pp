class facter::params(
){

  $facts_file             = 'facts.txt'
  $facts_d_mode           = '0755'
  $facts_file_mode        = '0644'
  $package_ensure         = 'present'
  $manage_package         = true
  $manage_facts_d_dir     = true
  $purge_facts_d          = false
  $ensure_facter_symlink  = false
  $facts_hash             = {}
  $facts_hash_hiera_merge = false
  $path_to_facter_symlink = '/usr/local/bin/facter'

  case $::kernel {
    'Linux': {
      $facts_d_dir            = '/etc/facter/facts.d'
      $path_to_facter         = '/usr/bin/facter'
      $facts_d_owner          = 'root'
      $facts_d_group          = 'root'
      $facts_file_owner       = 'root'
      $facts_file_group       = 'root'
      $package_name           = 'facter'
    }
    'windows': {
      $facts_d_dir            = 'C:/ProgramData/PuppetLabs/facter/facts.d'
      $path_to_facter         = 'C:/Program Files/Puppet Labs/Puppet/bin/facter.bat'
      $facts_d_owner          = 'BUILTIN\Administrators'
      $facts_d_group          = 'BUILTIN\Administrators'
      $facts_file_owner       = 'BUILTIN\Administrators'
      $facts_file_group       = 'BUILTIN\Administrators'
      $package_name           = 'facter'
    }
    default: {
      fail("${::kernel} not supported")
    }
  }

}
