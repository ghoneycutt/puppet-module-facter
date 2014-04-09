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

    it {
      should contain_file('facts_d_directory').with({
        'ensure' => 'directory',
        'path'   => '/etc/facter/facts.d',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755',
        'require' => 'Common::Mkdir_p[/etc/facter/facts.d]',
      })
    }

    it {
      should contain_exec('mkdir_p-/etc/facter/facts.d').with({
        'command' => 'mkdir -p /etc/facter/facts.d',
        'unless'  => 'test -d /etc/facter/facts.d',
      })
    }
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
        'ensure' => 'directory',
        'path'   => '/etc/facter/facts.d',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755',
        'require' => 'Common::Mkdir_p[/etc/facter/facts.d]',
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
        'ensure' => 'directory',
        'path'   => '/etc/facter/facts.d',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0755',
        'require' => 'Common::Mkdir_p[/etc/facter/facts.d]',
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
        'require' => 'Common::Mkdir_p[/etc/facter/facts.d]',
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
        :facts => {
          'fact1' => {
            'value' => 'fact1value',
          },
          'fact2' => {
            'value' => 'fact2value',
            'match' => 'fact2match',
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
        'require' => 'File[facts_d_directory]',
      })
    }

    it { should contain_class('Facter::Fact[fact1]')}
    it { should contain_class('Facter::Fact[fact2]')}
    it { should contain_class('facter') }
    it { should contain_package('facter') }
    it { should contain_file('facts_d_directory') }
    it { should contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with facts specified as a hash with different file and folder on RedHat' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) do
      {
        :facts_file => "file.txt",
        :facts => {
          'fact1' => {
            'value' => 'fact1value',
          },
          'fact2' => {
            'value' => 'fact2value',
            'file'  => 'file2.txt',
          },
          'fact3' => {
            'value'     => 'fact3value',
            'match'     => 'fact3match',
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
        'require' => 'File[facts_d_directory]',
      })
    }

    it { should contain_file('facts_file_fact2').with({
        'ensure'  => 'file',
        'path'    => '/etc/facter/facts.d/file2.txt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'File[facts_d_directory]',
      })
    }

    it { should contain_file('facts_file_fact3').with({
        'ensure'  => 'file',
        'path'    => '/etc/facts3/file3.txt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'require' => 'File[facts_d_directory]',
      })
    }

    it { should contain_class('Facter::Fact[fact1]')}
    it { should contain_class('Facter::Fact[fact2]')}
    it { should contain_class('Facter::Fact[fact3]')}
    it { should contain_class('facter') }
    it { should contain_package('facter') }
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
        :facts => {
          'fact' => {
            'value' => 'value',
            'match' => 'match',
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
        'require' => 'Common::Mkdir_p[/etc/puppet/facter/facts.d]',
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
        'require' => 'File[facts_d_directory]',
      })
    }

    it { should contain_class('Facter::Fact[fact]')}
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
    let(:params) { { :facts => ['array','is','invalid'] } }

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

end
