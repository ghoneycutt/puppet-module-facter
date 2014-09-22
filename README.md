# puppet-module-facter
===

[![Build Status](https://travis-ci.org/ghoneycutt/puppet-module-facter.png?branch=master)](https://travis-ci.org/ghoneycutt/puppet-module-facter)

Puppet module to manage Facter

===

# Compatibility
---------------
This module is built for use with Puppet v3 and supports Ruby v1.8.7, v1.9.3, v2.0.0 and v2.1.0.

===

# Parameters
------------

manage_package
--------------
Boolean to manage the package resource.

- *Default*: true

package_name
------------
String or Array of package(s) for facter.

- *Default*: 'facter'

package_ensure
--------------
String for ensure parameter to facter package.

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

path_to_facter
--------------
Path to facter to create symlink from.  Required if ensure_facter_symlink is true.

- *Default*: '/usr/bin/facter'

path_to_facter_symlink
----------------------
Path to symlink for facter.  Required if ensure_facter_symlink is true.

- *Default*: '/usr/local/bin/facter'

ensure_facter_symlink
---------------------
Boolean for ensuring a symlink for path_to_facter to symlink_facter_target. This is useful if you install facter in a non-standard location that is not in your $PATH.

- *Default*: false

facts
-----
Hash of facts to be passed to facter::fact with create_resources().

- *Default*: undef

facts_file
----------
Filename under `facts_d_dir` to place facts in

- *Default*: facts.txt

facts_file_owner
----------------
Owner of facts_file.

- *Default*: root

facts_d_group
-------------
Group of facst_file.

- *Default*: root

facts_d_mode
------------
Four digit mode of facts_file.

- *Default*: 0644

===

# Define `facter::fact`

Ensures a fact is present in the fact file with stdlib file_line() in fact=value format.

## Usage
You can optionally specify a hash of external facts in Hiera.
<pre>
---
facter::facts:
  role:
    value: 'puppetmaster'
  location:
    value: 'RNB'
    file: 'location.txt'
</pre>

The above configuration in Hiera would produce `/etc/facter/facts.d/facts.txt` with the following content.
<pre>
role=puppetmaster
</pre>

It would also produce `/etc/facter/facts.d/location.txt` with the following content.
<pre>
location=RNB
</pre>

value
-----
Value for the fact

- *Required*

fact
----
Name of the fact

- *Default*: $name

file
----
File under `facts_dir` in which to place the fact.

- *Default*: 'facts.txt'

facts_dir
---------
Path to facts.d directory.

- *Default*: '/etc/facter/facts.d'
