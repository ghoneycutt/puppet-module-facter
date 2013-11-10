require 'spec_helper'
describe 'facter' do

  context 'with default options' do
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should include_class('facter') }

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

  context 'with all options specified' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) do
      { :package_name   => 'myfacter',
        :package_ensure => 'absent',
        :facts_d_dir    => '/etc/puppet/facter/facts.d',
        :facts_d_owner  => 'puppet',
        :facts_d_group  => 'puppet',
        :facts_d_mode   => '0775',
      }
    end

    it { should include_class('facter') }

    it {
      should contain_package('facter').with({
        'ensure' => 'absent',
        'name'   => 'myfacter',
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
  end

  context 'with invalid package_ensure param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :package_ensure => 'invalid' } }

    it do
      expect {
        should include_class('facter')
      }.to raise_error(Puppet::Error,/facter::package_ensure must be \'present\' or \'absent\'. Detected value is <invalid>./)
    end
  end

  context 'with invalid facts_d_dir param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :facts_d_dir => 'invalid/path/statement' } }

    it do
      expect {
        should include_class('facter')
      }.to raise_error(Puppet::Error)
    end
  end

  context 'with invalid facts_d_mode param' do
    let(:facts) { { :osfamily => 'RedHat' } }
    let(:params) { { :facts_d_mode => '755' } }

    it do
      expect {
        should include_class('facter')
      }.to raise_error(Puppet::Error,/facter::facts_d_mode must be a four digit mode. Detected value is <755>./)
    end
  end
end
