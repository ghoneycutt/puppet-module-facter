require 'spec_helper'

describe 'facter' do
  context 'on RedHat' do
    redhat = {
      supported_os: [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['7'],
        },
      ],
    }
    on_supported_os(redhat).each do |os, os_facts|
      let(:facts) do
        os_facts
      end
      context 'with default options' do
    
        it { should compile.with_all_deps }
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
            'creates' => '/etc/facter/facts.d',
            'path'    => '/bin:/usr/bin',
          })
        }
      end
    
      describe 'with purge_facts_d' do
        [true, false].each do |value|
          context "set to #{value}" do
            let(:params) { { :purge_facts_d => value } }
    
            it {
              should contain_file('facts_d_directory').with({
                'ensure'  => 'directory',
                'path'    => '/etc/facter/facts.d',
                'owner'   => 'root',
                'group'   => 'root',
                'mode'    => '0755',
                'purge'   => value,
                'recurse' => value,
                'require' => 'Exec[mkdir_p-/etc/facter/facts.d]',
              })
            }
          end
        end
      end
    
      describe 'the package should not be managed' do
        it { should_not contain_package('facter') }
      end
    
      context 'with default options with manage_facts_d_dir = false' do
        let(:params) { { :manage_facts_d_dir => false } }
    
        it { should contain_class('facter') }
    
        it { should_not contain_file('facts_d_directory') }
    
        it { should_not contain_exec('mkdir_p-/etc/facter/facts.d') }
      end
    
      context 'with default options with manage_facts_d_dir = true' do
        let(:params) { { :manage_facts_d_dir => true } }
    
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
            'creates' => '/etc/facter/facts.d',
            'path'    => '/bin:/usr/bin',
          })
        }
      end
        
      context 'with facts specified as a hash' do
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
    
      context 'with facts specified as a hash with different file and facts_dir' do
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
            }
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
            'creates' => '/etc/puppet/facter/facts.d',
            'path'    => '/bin:/usr/bin',
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
            
      describe 'with facter::facts_hash_hiera_merge' do
        let :facts do
          os_facts.merge({
            :fqdn            => 'hieramerge.example.local',
            :parameter_tests => 'facts_hash_hiera_merge',
          })
        end
    
        context 'set to valid value true' do
          let(:params) { { :facts_hash_hiera_merge => true } }
    
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
          let(:params) { { :facts_hash_hiera_merge => false } }
    
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
      end
    
      describe 'variable type and content validations' do
        # set needed custom facts and variables
        let(:facts) do
          os_facts.merge({
           :fqdn => 'hieramerge.example.local',
          })
        end
        let(:validation_params) do
          {
            #:param => 'value',
          }
        end
    
        validations = {
          'Boolean' => {
            :name    => %w(manage_facts_d_dir purge_facts_d ensure_facter_symlink facts_hash_hiera_merge),
            :valid   => [true, false], 
            :invalid => ['invalid', 3, 2.42, %w(array), { 'ha' => 'sh' }, nil],
            :message => 'expects a Boolean value, got',
          },
          'Stdlib::Absolutepath' => {
            :name    => %w(facts_d_dir path_to_facter path_to_facter_symlink),
            :valid   => ['/absolute/filepath', '/absolute/directory/'],
            :invalid => ['../invalid', '', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
            :message => 'expects a Stdlib::Absolutepath',
          },
          'String[1]' => {
            :name    => %w(facts_d_owner facts_d_group facts_file facts_file_owner facts_file_group),
            :valid   => ['string'],
            :invalid => ['', %w(array), { 'ha' => 'sh' }, 3, 2.42, true, false],
            :message => '(expects a String value, got|expects a String\[1\] value, got)',
          },
          'Optional[Stdlib::Filemode]' => {
            :name    => %w(facts_d_mode facts_file_mode),
            :valid   => ['0777', :undef],
            :invalid => ['8888', 'invalid', 3, 2.42, %w(array), { 'ha' => 'sh' }, true, false],
            :message => '(expects a match for Stdlib::Filemode)',
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
    end # on_support_os(redhat)
  end # context 'on RedHat'

  context 'on Debian' do
    debian = {
      supported_os: [
        {
          'operatingsystem'        => 'Ubuntu',
          'operatingsystemrelease' => ['18.04'],
        },
      ],
    }
    on_supported_os(debian).each do |os, os_facts|
      let(:facts) do
        os_facts
      end

      it { should compile.with_all_deps }
      it { should contain_class('facter') }

      describe 'with ensure_facter_symlink' do
        context "set to true (default)" do
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
          let(:params) { { :ensure_facter_symlink => false } }
  
          it { should_not contain_file('facter_symlink') }
        end
    
        context 'enabled with all params specified' do
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
      end # describe 'with ensure_facter_symlink'
    end # on_support_os(debian)
  end # context 'on Debian'

  context 'on Windows' do
    windows = {
      supported_os: [
        {
          'operatingsystem'        => 'windows',
          'operatingsystemrelease' => ['2016'],
        },
      ],
    }
    on_supported_os(windows).each do |os, os_facts|
      let(:facts) do
        os_facts.merge({
          path: 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
        })
      end
      context 'with default options' do
        it { should compile.with_all_deps }
        it { should contain_class('facter') }

        it { should contain_file('facts_file').with({
            'ensure'  => 'file',
            'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d\facts.txt',
            'owner'   => 'NT AUTHORITY\SYSTEM',
            'group'   => 'NT AUTHORITY\SYSTEM',
          })
        }
    
        it {
          should contain_file('facts_d_directory').with({
            'ensure'  => 'directory',
            'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d',
            'owner'   => 'NT AUTHORITY\SYSTEM',
            'group'   => 'NT AUTHORITY\SYSTEM',
            'purge'   => false,
            'recurse' => false,
            'require' => 'Exec[mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d]',
          })
        }
    
        it {
          should contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d').with({
            'command' => 'cmd /c mkdir C:\ProgramData\PuppetLabs\facter\facts.d',
            'creates' => 'C:\ProgramData\PuppetLabs\facter\facts.d',
            'path'    => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
          })
        }
      end
    
      describe 'with purge_facts_d' do
        [true, false].each do |value|
          context "set to #{value}" do
            let(:params) { { :purge_facts_d => value } }
    
            it {
              should contain_file('facts_d_directory').with({
                'ensure'  => 'directory',
                'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d',
                'owner'   => 'NT AUTHORITY\SYSTEM',
                'group'   => 'NT AUTHORITY\SYSTEM',
                'purge'   => value,
                'recurse' => value,
                'require' => 'Exec[mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d]',
              })
            }
          end
        end
      end
    
      describe 'the package should not be managed' do
        it { should_not contain_package('facter') }
      end
    
      context 'with default options with manage_facts_d_dir = false' do
        let(:params) { { :manage_facts_d_dir => false } }
    
        it { should contain_class('facter') }
    
        it { should_not contain_file('facts_d_directory') }
    
        it { should_not contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d') }
      end
    
      context 'with default options with manage_facts_d_dir = true' do
        let(:params) { { :manage_facts_d_dir => true } }
    
        it { should contain_class('facter') }
    
        it {
          should contain_file('facts_d_directory').with({
            'ensure'  => 'directory',
            'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d',
            'owner'   => 'NT AUTHORITY\SYSTEM',
            'group'   => 'NT AUTHORITY\SYSTEM',
            'mode'    => '0755',
            'require' => 'Exec[mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d]',
          })
        }
    
        it {
          should contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d').with({
            'command' => 'cmd /c mkdir C:\ProgramData\PuppetLabs\facter\facts.d',
            'creates' => 'C:\ProgramData\PuppetLabs\facter\facts.d',
            'path'    => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
          })
        }
      end

      context 'with all options specified' do
        let(:params) do
          {
            :facts_d_dir      => 'C:\ProgramData\PuppetLabs\facter\facts.d',
            :facts_d_owner    => 'puppet',
            :facts_d_group    => 'puppet',
            :facts_file       => 'file.txt',
            :facts_file_owner => 'puppet',
            :facts_file_group => 'puppet',
            :facts_hash => {
              'fact' => {
                'value' => 'value',
              },
            }
          }
        end
    
        it { should contain_class('facter') }
        it {
          should contain_file('facts_d_directory').with({
            'ensure'  => 'directory',
            'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d',
            'owner'   => 'puppet',
            'group'   => 'puppet',
            'purge'   => false,
            'recurse' => false,
            'require' => 'Exec[mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d]',
          })
        }
    
        it {
          should contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d').with({
            'command' => 'cmd /c mkdir C:\ProgramData\PuppetLabs\facter\facts.d',
            'creates' => 'C:\ProgramData\PuppetLabs\facter\facts.d',
            'path'    => 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
          })
        }
    
        it { should contain_file('facts_file').with({
            'ensure'  => 'file',
            'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d\file.txt',
            'owner'   => 'puppet',
            'group'   => 'puppet',
          })
        }
    
        it {
          should contain_file_line('fact_line_fact').with({
            'line' => 'fact=value',
          })
        }
      end # context 'with all options specified'
    end # on_support_os(windows)
  end # context 'on windows'  
end # describe 'facter'
