# puppet-module-facter
===

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-facter.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-facter)

Puppet module to manage Facter

===

# Compatibility
---------------
This module is built for use with Puppet v3

===

# Parameters
------------

manage_package
--------------
Boolean to manage the package resource.

- *Default*: true

package_name
------------
Name of package(s) for facter.

- *Default*: facter

package_ensure
--------------
String for ensure parameter to facter package. Valid values are 'present' and 'absent'.

- *Default*: present

manage_facts_d_dir
------------------
Boolean to manage the directory.

- *Default*: true

facts_d_dir
-----------
Path to facts.d directory.

- *Default*: /etc/facter/facts.d

facts_d_owner
-------------
Owner of facts.d directory.

- *Default*: root

facts_d_group
-------------
Group of facts.d directory.

- *Default*: root

facts_d_mode
------------
Four digit mode of facts.d directory.

- *Default*: 0755
