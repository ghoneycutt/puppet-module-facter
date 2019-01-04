require 'spec_helper'
describe 'facter' do

  it { should compile.with_all_deps }

  context 'with default options' do
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

    it {
      should contain_package('facter').with({
        'ensure' => 'present',
        'name'   => 'facter',
      })
    }

    it { should contain_file('facts_file').with({
        'ensure'  => 'file',
        'path'    => '/etc/facter/facts.d/facts.txt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }

    it {
      should contain_file('facts_d_directory').with({
        'ensure'  => 'directory',
        'path'    => '/etc/facter/facts.d',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'purge'   => false,
        'recurse' => false,
        'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
      })
    }

    it {
      should contain_exec('mkdir_p-/etc/facter/facts.d').with({
        'command' => 'mkdir -p /etc/facter/facts.d',
        'unless'  => 'test -d /etc/facter/facts.d',
      })
    }
  end

  describe 'with purge_facts_d' do
    ['true',true].each do |value|
      context "set to #{value}" do
        let(:params) { { :purge_facts_d => value } }
        let(:facts) { { :osfamily => 'RedHat' } }

        it {
          should contain_file('facts_d_directory').with({
            'ensure'  => 'directory',
            'path'    => '/etc/facter/facts.d',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'purge'   => true,
            'recurse' => true,
            'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
          })
        }
      end
    end
    ['false',false].each do |value|
      context "set to #{value}" do
        let(:params) { { :purge_facts_d => value } }
        let(:facts) { { :osfamily => 'RedHat' } }

        it {
          should contain_file('facts_d_directory').with({
            'ensure'  => 'directory',
            'path'    => '/etc/facter/facts.d',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0755',
            'purge'   => false,
            'recurse' => false,
            'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
          })
        }
      end
    end
    context 'set to an invalid type' do
      let(:params) { { :purge_facts_d => ['invalid', 'type'] } }

      it do
        expect {
          should contain_class('facter')
        }.to raise_error(Puppet::Error,/\["invalid", "type"\] is not a boolean/)
      end
    end
  end

  describe 'on puppet5 the package should not be managed' do
    let(:facts) { { :puppetversion => '5.3.0' } }
    [true,false].each do |value|
      context "with manage_package set to #{value}" do
        let(:params) { { :manage_package => value } }

        it { should_not contain_package('facter') }
      end
    end
  end

  describe 'on puppet4 the package should not be managed' do
    let(:facts) { { :puppetversion => '4.10.0' } }
    [true,false].each do |value|
      context "with manage_package set to #{value}" do
        let(:params) { { :manage_package => value } }

        it { should_not contain_package('facter') }
      end
    end
  end

  context 'with default options and stringified \'true\' for manage_package param' do
    let(:params) { { :manage_package => 'true' } }
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

    it {
      should contain_package('facter').with({
        'ensure' => 'present',
        'name'   => 'facter',
      })
    }

    it {
      should contain_file('facts_d_directory').with({
        'ensure'  => 'directory',
        'path'    => '/etc/facter/facts.d',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'purge'   => false,
        'recurse' => false,
        'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
      })
    }

    it {
      should contain_exec('mkdir_p-/etc/facter/facts.d').with({
        'command' => 'mkdir -p /etc/facter/facts.d',
        'unless'  => 'test -d /etc/facter/facts.d',
      })
    }
  end

  context 'with default options and stringified \'true\' for manage_facts_d_dir param' do
    let(:params) { { :manage_facts_d_dir => 'true' } }
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

    it {
      should contain_package('facter').with({
        'ensure' => 'present',
        'name'   => 'facter',
      })
    }

    it {
      should contain_file('facts_d_directory').with({
        'ensure'  => 'directory',
        'path'    => '/etc/facter/facts.d',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'purge'   => false,
        'recurse' => false,
        'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
      })
    }

    it {
      should contain_exec('mkdir_p-/etc/facter/facts.d').with({
        'command' => 'mkdir -p /etc/facter/facts.d',
        'unless'  => 'test -d /etc/facter/facts.d',
      })
    }
  end

  context 'with default options with manage_package = true and manage_facts_d_dir = false' do
    let(:params) do
      { :manage_package     => true,
        :manage_facts_d_dir => false,
      }
    end
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

    it {
      should contain_package('facter').with({
        'ensure' => 'present',
        'name'   => 'facter',
      })
    }

    it { should_not contain_file('facts_d_directory') }

    it { should_not contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with default options with manage_package = false and manage_facts_d_dir = true' do
    let(:params) do
      { :manage_package     => false,
        :manage_facts_d_dir => true,
      }
    end
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

    it { should_not contain_package('facter') }

    it {
      should contain_file('facts_d_directory').with({
        'ensure' => 'directory',
        'path'   => '/etc/facter/facts.d',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755',
        'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
      })
    }

    it {
      should contain_exec('mkdir_p-/etc/facter/facts.d').with({
        'command' => 'mkdir -p /etc/facter/facts.d',
        'unless'  => 'test -d /etc/facter/facts.d',
      })
    }
  end

  context 'with default options with manage_package = false and manage_facts_d_dir = false' do
    let(:params) do
      { :manage_package     => false,
        :manage_facts_d_dir => false,
      }
    end
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

    it { should_not contain_package('facter') }

    it { should_not contain_file('facts_d_directory') }

    it { should_not contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with facts specified as a hash on RedHat' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) do
      {
        :facts_hash => {
          'fact1' => {
            'value' => 'fact1value',
          },
          'fact2' => {
            'value' => 'fact2value',
          },
        }
      }
    end

    it { should contain_file('facts_file').with({
        'ensure'  => 'file',
        'path'    => '/etc/facter/facts.d/facts.txt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }

    it {
      should contain_file_line('fact_line_fact1').with({
        'line' => 'fact1=fact1value',
      })
    }

    it {
      should contain_file_line('fact_line_fact2').with({
        'line' => 'fact2=fact2value',
      })
    }

    it { should contain_file('facts_d_directory') }
    it { should contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with facts specified as a hash with different file and facts_dir on RedHat' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) do
      {
        :facts_file => "file.txt",
        :facts_hash => {
          'fact1' => {
            'value' => 'fact1value',
          },
          'fact2' => {
            'value' => 'fact2value',
            'file'  => 'file2.txt',
          },
          'fact3' => {
            'value'     => 'fact3value',
            'file'      => 'file3.txt',
            'facts_dir' => '/etc/facts3',
          },
        }
      }
    end

    it { should contain_file('facts_file').with({
        'ensure'  => 'file',
        'path'    => '/etc/facter/facts.d/file.txt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }

    it { should contain_file('facts_file_fact2').with({
        'ensure'  => 'file',
        'path'    => '/etc/facter/facts.d/file2.txt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }

    it { should contain_file('facts_file_fact3').with({
        'ensure'  => 'file',
        'path'    => '/etc/facts3/file3.txt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }

    it {
      should contain_file_line('fact_line_fact1').with({
        'line' => 'fact1=fact1value',
      })
    }

    it {
      should contain_file_line('fact_line_fact2').with({
        'line' => 'fact2=fact2value',
      })
    }

    it {
      should contain_file_line('fact_line_fact3').with({
        'line' => 'fact3=fact3value',
      })
    }

    it { should contain_file('facts_d_directory') }
    it { should contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with all options specified' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) do
      { :package_name     => 'myfacter',
        :package_ensure   => 'absent',
        :facts_d_dir      => '/etc/puppet/facter/facts.d',
        :facts_d_owner    => 'puppet',
        :facts_d_group    => 'puppet',
        :facts_d_mode     => '0775',
        :facts_file       => 'file.txt',
        :facts_file_owner => 'puppet',
        :facts_file_group => 'puppet',
        :facts_file_mode  => '0775',
        :facts_hash => {
          'fact' => {
            'value' => 'value',
          },
        }
      }
    end

    it { should contain_class('facter') }

    it {
      should contain_package('myfacter').with({
        'ensure' => 'absent',
      })
    }

    it {
      should contain_file('facts_d_directory').with({
        'ensure'  => 'directory',
        'path'    => '/etc/puppet/facter/facts.d',
        'owner'   => 'puppet',
        'group'   => 'puppet',
        'mode'    => '0775',
        'purge'   => false,
        'recurse' => false,
        'require' => 'Exec[mkdir_p-/etc/puppet/facter/facts.d]',
      })
    }

    it {
      should contain_exec('mkdir_p-/etc/puppet/facter/facts.d').with({
        'command' => 'mkdir -p /etc/puppet/facter/facts.d',
        'unless'  => 'test -d /etc/puppet/facter/facts.d',
      })
    }

    it { should contain_file('facts_file').with({
        'ensure'  => 'file',
        'path'    => '/etc/puppet/facter/facts.d/file.txt',
        'owner'   => 'puppet',
        'group'   => 'puppet',
        'mode'    => '0775',
      })
    }

    it {
      should contain_file_line('fact_line_fact').with({
        'line' => 'fact=value',
      })
    }
  end

  describe 'with package_name set to' do
    context 'a string' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :package_name => 'myfacter' } }

      it {
        should contain_package('myfacter').with({
          'ensure' => 'present',
        })
      }
    end

    context 'an array' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :package_name => ['facter','facterfoo'] } }

      it {
        should contain_package('facter').with({
          'ensure' => 'present',
        })
      }

      it {
        should contain_package('facterfoo').with({
          'ensure' => 'present',
        })
      }
    end

    context 'an invalid type (boolean)' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :package_name => true } }

      it do
        expect {
          should contain_class('facter')
        }.to raise_error(Puppet::Error,/facter::package_name must be a string or an array./)
      end
    end
  end

  describe 'with package_ensure parameter' do
    ['present','absent','23'].each do |value|
      context "set to a valid string value of #{value}" do
        let(:facts) { { :osfamily => 'RedHat' } }
        let(:params) { { :package_ensure => value } }

        it {
          should contain_package('facter').with({
            'ensure' => value,
          })
        }
      end
    end

    context 'set to a non-string value' do
      let(:facts) { { :osfamily => 'RedHat' } }
      let(:params) { { :package_ensure => ['invalid'] } }

      it do
        expect {
          should contain_class('facter')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  context 'with invalid facts_d_dir param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :facts_d_dir => 'invalid/path/statement' } }

    it do
      expect {
        should contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with invalid facts_d_mode param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :facts_d_mode => '751' } }

    it do
      expect {
        should contain_class('facter')
      }.to raise_error(Puppet::Error,/facter::facts_d_mode must be a four digit mode. Detected value is <751>./)
    end
  end

  context 'with invalid manage_package param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :manage_package => ['array','is','invalid'] } }

    it do
      expect {
        should contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with invalid manage_facts_d_dir param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :manage_facts_d_dir => ['array','is','invalid'] } }

    it do
      expect {
        should contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  describe 'with ensure_facter_symlink' do
    ['true',true].each do |value|
      context "set to #{value} (default)" do
        let(:facts) { { :osfamily => 'Debian' } }
        let(:params) { { :ensure_facter_symlink => value } }

        it {
          should contain_file('facter_symlink').with({
            'ensure'  => 'link',
            'path'    => '/usr/local/bin/facter',
            'target'  => '/usr/bin/facter',
          })
        }
      end
    end

    ['false',false].each do |value|
      context "set to #{value} (default)" do
        let(:facts) { { :osfamily => 'Debian' } }
        let(:params) { { :ensure_facter_symlink => value } }

        it { should_not contain_file('facter_symlink') }
      end
    end

    context 'enabled with all params specified' do
      let(:facts) { { :osfamily => 'Debian' } }
      let(:params) do
        { :ensure_facter_symlink  => true,
          :path_to_facter         => '/foo/bar',
          :path_to_facter_symlink => '/bar',
        }
      end

      it {
        should contain_file('facter_symlink').with({
          'ensure'  => 'link',
          'path'    => '/bar',
          'target'  => '/foo/bar',
        })
      }
    end
  end

  describe 'with invalid path for' do
    context 'path_to_facter' do
      let(:params) do
        {
          :path_to_facter => 'invalid/path',
        }
      end

      it do
        expect {
          should contain_class('facter')
        }.to raise_error(Puppet::Error)
      end
    end

    context 'path_to_facter_symlink' do
      let(:params) do
        {
          :path_to_facter_symlink => 'invalid/path',
        }
      end

      it do
        expect {
          should contain_class('facter')
        }.to raise_error(Puppet::Error)
      end
    end
  end

  context 'with invalid facts param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :facts_hash => ['array','is','invalid'] } }

    it do
      expect {
        should contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with invalid fact_file param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :fact_file => ['array','is','invalid'] } }

    it do
      expect {
        should contain_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  describe 'with facter::facts_hash_hiera_merge' do
    let :facts do
      {
        :osfamily        => 'RedHat',
        :fqdn            => 'hieramerge.example.local',
        :parameter_tests => 'facts_hash_hiera_merge',
      }
    end

    context 'set to valid value true' do
      let(:params) { { :facts_hash_hiera_merge => 'true' } }

      it { should have_facter__fact_resource_count(2) }
      it do
        should contain_facter__fact('role').with({
          'file'      => 'facts.txt',
          'facts_dir' => '/etc/facter/facts.d',
          'value'     => 'puppetmaster',
        })
      end
      it do
        should contain_facter__fact('location').with({
          'file'      => 'location.txt',
          'facts_dir' => '/etc/facter/facts.d',
          'value'     => 'RNB',
        })
      end
    end

    context 'set to valid value false' do
      let(:params) { { :facts_hash_hiera_merge => 'false' } }

      it { should have_facter__fact_resource_count(1) }
      it do
        should contain_facter__fact('role').with({
          'file'      => 'facts.txt',
          'facts_dir' => '/etc/facter/facts.d',
          'value'     => 'puppetmaster',
        })
      end
      it { should_not contain_facter__fact('location') }
    end

    context 'set to invalid value <invalid>' do
      let(:params) { { :facts_hash_hiera_merge => 'invalid' } }

      it 'should fail' do
        expect {
          should contain_class('facter')
        }.to raise_error(Puppet::Error,/str2bool\(\): Unknown type of boolean given/)
      end
    end
  end

  describe 'variable type and content validations' do
    # set needed custom facts and variables
    let(:facts) do
      {
       :fqdn => 'hieramerge.example.local',
      }
    end
    let(:validation_params) do
      {
        #:param => 'value',
      }
    end

    validations = {
      'bool_stringified' => {
        :name    => %w(facts_hash_hiera_merge),
        :valid   => [true, 'true', false, 'false'],
        :invalid => ['invalid', 3, 2.42, %w(array), { 'ha' => 'sh' }, nil],
        :message => '(is not a boolean|Unknown type of boolean)',
      },
    }

    validations.sort.each do |type, var|
      var[:name].each do |var_name|
        var[:valid].each do |valid|
          context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
            let(:params) { validation_params.merge({ :"#{var_name}" => valid, }) }
            it { should compile }
          end
        end

        var[:invalid].each do |invalid|
          context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
            let(:params) { validation_params.merge({ :"#{var_name}" => invalid, }) }
            it 'should fail' do
              expect do
                should contain_class(subject)
              end.to raise_error(Puppet::Error, /#{var[:message]}/)
            end
          end
        end
      end # var[:name].each
    end # validations.sort.each
  end # describe 'variable type and content validations'

end
