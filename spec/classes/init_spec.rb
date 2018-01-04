require 'spec_helper'
describe 'facter' do

  it { should compile.with_all_deps }

  context 'with default options' do
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

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

    it {
      should contain_exec('mkdir_p-/etc/puppetlabs/facter').with({
        'command' => 'mkdir -p /etc/puppetlabs/facter',
        'unless'  => 'test -d /etc/puppetlabs/facter',
      })
    }

    it {
      should contain_file('/etc/puppetlabs/facter').with({
        'ensure'  => 'directory',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'require' => 'Exec[mkdir_p-/etc/puppetlabs/facter]',
      })
    }

    it { should_not contain_file('/etc/puppetlabs/facter/facter.conf') }
  end

  describe 'with purge_facts_d' do
    context "set to true" do
      let(:params) { { :purge_facts_d => true } }
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
    context "set to false" do
      let(:params) { { :purge_facts_d => false } }
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

  context 'with manage_facts_d_dir = false' do
    let(:params) do
      {
        :manage_facts_d_dir => false,
      }
    end
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

    it { should_not contain_file('facts_d_directory') }

    it { should_not contain_exec('mkdir_p-/etc/facter/facts.d') }
  end

  context 'with manage_facts_d_dir = true' do
    let(:params) do
      {
        :manage_facts_d_dir => true,
      }
    end
    let(:facts) { { :osfamily => 'RedHat' } }

    it { should contain_class('facter') }

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
      {
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
        },
        :facter_conf => {
          'global' => { 'external-dir' => ['/foo'] },
        },
      }
    end

    it { should contain_class('facter') }

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

    it {
      should contain_exec('mkdir_p-/etc/puppetlabs/facter').with({
        'command' => 'mkdir -p /etc/puppetlabs/facter',
        'unless'  => 'test -d /etc/puppetlabs/facter',
      })
    }

    it {
      should contain_file('/etc/puppetlabs/facter').with({
        'ensure'  => 'directory',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0755',
        'require' => 'Exec[mkdir_p-/etc/puppetlabs/facter]',
      })
    }

    it {
      should contain_file('/etc/puppetlabs/facter/facter.conf').with({
        'ensure' => 'file',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644',
        'content' => '# File managed by Puppet, do not edit
{
  "global": {
    "external-dir": [
      "/foo"
    ]
  }
}
'
      })
    }
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
      }.to raise_error(Puppet::Error,/Pattern\[\/\^\[0124\]\{1\}\[0-7\]\{3\}\$\/\]/)
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
    context "set to true (default)" do
      let(:facts) { { :osfamily => 'Debian' } }
      let(:params) { { :ensure_facter_symlink => true } }

      it {
        should contain_file('facter_symlink').with({
          'ensure'  => 'link',
          'path'    => '/usr/local/bin/facter',
          'target'  => '/opt/puppetlabs/bin/facter',
        })
      }
    end

    context "set to false (default)" do
      let(:facts) { { :osfamily => 'Debian' } }
      let(:params) { { :ensure_facter_symlink => false } }

      it { should_not contain_file('facter_symlink') }
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
      'boolean' => {
        :name    => %w(facts_hash_hiera_merge purge_facts_d),
        :valid   => [true, false],
        :invalid => ['invalid', 'true', 'false', 3, 2.42, %w(array), { 'ha' => 'sh' }, nil],
        :message => 'expects a Boolean value',
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
