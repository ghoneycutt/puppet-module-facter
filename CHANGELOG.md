### v3.1.1
  Bugfix for hiera_merge when no facts are specified

### v3.1.0
  Add ability to control hiera lookup method

### v3.0.0
  This version will always manage the facts.txt.
  Also adds support for Puppet v4.

### v2.1.0
  Add param to purge facts.d, support future parser

### v2.0.0
  Changed facter::facts to facter::facts_hash as $facts is now reserved for use
  with trusted node data.
