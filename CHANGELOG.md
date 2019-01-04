### v3.5.0 - 2019-01-03
  Support Puppet v6

### v3.4.0 - 2017-11-01
  Support Puppet v5

### v3.3.1 - 2017-07-17
  Do not manage package with Puppet v4 as it uses the AIO and facter is
  part of the puppet-agent package.

### v3.3.0 - 2016-11-18
  Support Ruby 2.3.1

### v3.2.0 - 2016-06-03
  Support Puppet v4 w/ strict variables

### v3.1.1 - 2016-01-13
  Bugfix for hiera_merge when no facts are specified

### v3.1.0 - 2015-12-11
  Add ability to control hiera lookup method

### v3.0.0 - 2015-11-04
  This version will always manage the facts.txt.
  Also adds support for Puppet v4.

### v2.1.0 - 2015-07-23
  Add param to purge facts.d, support future parser

### v2.0.0 - 2015-02-01
  Changed facter::facts to facter::facts_hash as $facts is now reserved for use
  with trusted node data.

### v1.3.2 - 2015-01-06
  Support future parser

### v1.3.1 - 2014-11-25

  Fix cyclic dependency

### v1.3.0 - 2014-09-22

  Support external facts

### v1.2.1 - 2014-08-06

  Add ability to specify arbitrary string for package_ensure

### v1.2.0 - 2014-04-29

  Ability to specify a symlink to facter
  Support Puppet v3.5.1
  Support Ruby v2.1.0 on Puppet v3.5.1

### v1.1.2 - 2014-01-29

  Support Puppet v3.4 and Ruby v2.0.0

### v1.1.1 - 2014-01-23

  Bugfix in error message

### v1.1.0 - 2013-11-11

  Add ability to toggle management of resources

### v1.0.0 - 2013-11-10

  First release
