require 'spec_helper'

describe 'facter' do
  # This module is meant to work on all POSIX systems. Because of this, we just
  # use the most popular here. There is no logic in the module based on the
  # platform, so no need to test different POSIX platforms.
  context 'on RedHat' do
    redhat = {
      supported_os: [
        {
          'operatingsystem'        => 'RedHat',
          'operatingsystemrelease' => ['7'],
        },
      ],
    }
    on_supported_os(redhat).each do |_os, os_facts|
      let(:facts) do
        os_facts
      end
      context 'with default options' do
        it { should compile.with_all_deps }
        it { should contain_class('facter') }

        it {
          should contain_concat('facts_file').with({
            'ensure'         => 'present',
            'path'           => '/etc/facter/facts.d/facts.txt',
            'owner'          => 'root',
            'group'          => 'root',
            'mode'           => '0644',
            'ensure_newline' => 'true',
          })
        }

        it {
          should contain_concat__fragment('facts_file-header').with({
            'target'  => 'facts_file',
            'content' => "# File managed by Puppet\n#DO NOT EDIT",
            'order'   => '00',
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

        it {
          should contain_concat('facts_file').with({
            'ensure'  => 'present',
            'path'    => '/etc/facter/facts.d/facts.txt',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact1').with({
            'content' => 'fact1=fact1value',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact2').with({
            'content' => 'fact2=fact2value',
          })
        }

        it { should contain_file('facts_d_directory') }
        it { should contain_exec('mkdir_p-/etc/facter/facts.d') }
      end

      context 'with structured_data_facts_hash specified' do
        let(:params) do
          {
            :structured_data_facts_hash => {
              'foo' => {
                'data' => {
                  'my_array' => ['one', 'two', 'three'],
                  'my_hash' => { 'k' => 'v' },
                },
              },
              'bar' => {
                'data' => {
                  'bar_array' => ['one', 'two', 'three'],
                },
                'file' => 'bar.yaml',
                'facts_dir' => '/factsdir',
              },
            }
          }
        end

        foo_content = <<-END.gsub(/^\s+\|/, '')
          |# This file is being maintained by Puppet.
          |# DO NOT EDIT
          |---
          |my_array:
          |- one
          |- two
          |- three
          |my_hash:
          |  k: v
        END

        bar_content = <<-END.gsub(/^\s+\|/, '')
          |# This file is being maintained by Puppet.
          |# DO NOT EDIT
          |---
          |bar_array:
          |- one
          |- two
          |- three
        END

        it { should contain_facter__structured_data_fact('foo') }
        it { should contain_facter__structured_data_fact('bar') }

        it {
          should contain_file('structured_data_fact_facts.yaml').with({
            'ensure'  => 'file',
            'path'    => '/etc/facter/facts.d/facts.yaml',
            'content' => foo_content,
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it {
          should contain_file('structured_data_fact_bar.yaml').with({
            'ensure'  => 'file',
            'path'    => '/factsdir/bar.yaml',
            'content' => bar_content,
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }
      end

      context 'with facts specified as a hash with different file and facts_dir' do
        let(:params) do
          {
            :facts_file => 'file.txt',
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

        it { should contain_facter__fact('fact1') }
        it { should contain_facter__fact('fact2') }
        it { should contain_facter__fact('fact3') }

        it {
          should contain_concat('facts_file').with({
            'ensure'  => 'present',
            'path'    => '/etc/facter/facts.d/file.txt',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it {
          should contain_concat('facts_file_fact2').with({
            'ensure'  => 'present',
            'path'    => '/etc/facter/facts.d/file2.txt',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it {
          should contain_concat('facts_file_fact3').with({
            'ensure'  => 'present',
            'path'    => '/etc/facts3/file3.txt',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact1').with({
            'content' => 'fact1=fact1value',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact2').with({
            'content' => 'fact2=fact2value',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact3').with({
            'content' => 'fact3=fact3value',
          })
        }

        it { should contain_file('facts_d_directory') }
        it { should contain_exec('mkdir_p-/etc/facter/facts.d') }
      end

      context 'with all options specified' do
        let(:params) do
          {
            :ensure_facter_symlink => true,
            :facts_d_dir           => '/etc/puppet/facter/facts.d',
            :facts_d_owner         => 'puppet',
            :facts_d_group         => 'puppet',
            :facts_d_mode          => '0775',
            :facts_file            => 'file.txt',
            :facts_file_owner      => 'puppet',
            :facts_file_group      => 'puppet',
            :facts_file_mode       => '0775',
            :facts_hash            => {
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

        it { should contain_facter__fact('fact') }

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

        it {
          should contain_file('facter_symlink').with({
            'ensure' => 'link',
            'path'   => '/usr/local/bin/facter',
            'target' => '/opt/puppetlabs/bin/facter',
          })
        }

        it {
          should contain_concat('facts_file').with({
            'ensure'  => 'present',
            'path'    => '/etc/puppet/facter/facts.d/file.txt',
            'owner'   => 'puppet',
            'group'   => 'puppet',
            'mode'    => '0775',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact').with({
            'content' => 'fact=value',
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

      describe 'variable type and content validations' do
        # set needed custom facts and variables
        let(:facts) do
          os_facts.merge({
           :fqdn => 'facter.example.local',
          })
        end
        let(:validation_params) do
          {
            #:param => 'value',
          }
        end

        validations = {
          'Boolean' => {
            :name    => ['manage_facts_d_dir', 'purge_facts_d', 'ensure_facter_symlink'],
            :valid   => [true, false],
            :invalid => ['invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }, nil],
            :message => 'expects a Boolean value, got',
          },
          'Stdlib::Absolutepath' => {
            :name    => ['facts_d_dir', 'path_to_facter', 'path_to_facter_symlink'],
            :valid   => ['/absolute/filepath', '/absolute/directory/'],
            :invalid => ['../invalid', '', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false, nil],
            :message => 'expects a Stdlib::Absolutepath',
          },
          'String[1]' => {
            :name    => ['facts_d_owner', 'facts_d_group', 'facts_file_owner', 'facts_file_group'],
            :valid   => ['string'],
            :invalid => ['', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false],
            :message => '(expects a String value, got|expects a String\[1\] value, got)',
          },
          'Pattern to match strings that end with .txt' => {
            :name    => ['facts_file'],
            :valid   => ['foo.txt'],
            :invalid => ['foo.text', 'foo-text', 'foo.text1', '', ['array'], { 'ha' => 'sh' }, 3, 2.42, true, false],
            :message => 'Error while evaluating a Resource Statement',
          },
          'Optional[Stdlib::Filemode]' => {
            :name    => ['facts_d_mode', 'facts_file_mode'],
            :valid   => ['0777', :undef],
            :invalid => ['8888', 'invalid', 3, 2.42, ['array'], { 'ha' => 'sh' }, true, false],
            :message => '(expects a match for Stdlib::Filemode)',
          },
        }

        validations.sort.each do |type, var|
          var[:name].each do |var_name|
            var[:valid].each do |valid|
              context "with #{var_name} (#{type}) set to valid #{valid} (as #{valid.class})" do
                let(:params) { validation_params.merge({ :"#{var_name}" => valid, }) }
                  # Without this, the coverage report will incorrectly mark these as untested.
                  if var_name == 'facts_d_dir' and ['/absolute/filepath', '/absolute/directory/'].include? valid
                    it { should contain_exec("mkdir_p-#{valid}") }
                  end
                it { should compile }
              end
            end

            var[:invalid].each do |invalid|
              context "with #{var_name} (#{type}) set to invalid #{invalid} (as #{invalid.class})" do
                let(:params) { validation_params.merge({ :"#{var_name}" => invalid, }) }
                it 'should fail' do
                  expect { should contain_class(subject) }.to raise_error(Puppet::Error, /#{var[:message]}/)
                end
              end
            end
          end # var[:name].each
        end # validations.sort.each
      end # describe 'variable type and content validations'
    end # on_support_os(redhat)
  end # context 'on RedHat'

  context 'on Windows' do
    windows = {
      supported_os: [
        {
          'operatingsystem'        => 'windows',
          'operatingsystemrelease' => ['2016'],
        },
      ],
    }
    on_supported_os(windows).each do |_os, os_facts|
      let(:facts) do
        os_facts.merge({
          path: 'C:\Program Files\Puppet Labs\Puppet\puppet\bin;C:\Program Files\Puppet Labs\Puppet\bin',
        })
      end
      context 'with default options' do
        it { should compile.with_all_deps }
        it { should contain_class('facter') }

        it {
          should contain_concat('facts_file').with({
            'ensure'         => 'present',
            'path'           => 'C:\ProgramData\PuppetLabs\facter\facts.d\facts.txt',
            'owner'          => 'NT AUTHORITY\SYSTEM',
            'group'          => 'NT AUTHORITY\SYSTEM',
            'ensure_newline' => 'true',
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
            'mode'    => nil,
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

        it { should_not contain_file('facter_symlink') }
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
                'mode'    => nil,
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
            'mode'    => nil,
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
            'mode'    => nil,
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

        it {
          should contain_concat('facts_file').with({
            'ensure'  => 'present',
            'path'    => 'C:\ProgramData\PuppetLabs\facter\facts.d\file.txt',
            'owner'   => 'puppet',
            'group'   => 'puppet',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact').with({
            'content' => 'fact=value',
          })
        }
      end # context 'with all options specified'
    end # on_support_os(windows)
  end # context 'on windows'
end # describe 'facter'
