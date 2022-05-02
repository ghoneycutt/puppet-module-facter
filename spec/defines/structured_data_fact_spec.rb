require 'spec_helper'

describe 'facter::structured_data_fact' do
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

      context 'with file and facts_dir specified' do
        let(:title) { 'fact1' }
        let(:params) do
          {
            :data => {
              'my_array' => ['one', 'two', 'three'],
              'my_hash' => { 'k' => 'v' },
            },
            :file => 'custom.yaml',
            :facts_dir => '/factsdir',
          }
        end

        it { should contain_class('facter') }

        # These must exist or the coverage report lists these incorrectly as
        # untouched resources. These resources are all from the facter class.
        it { should contain_file('facts_d_directory') }
        it { should contain_exec('mkdir_p-/etc/facter/facts.d') }

        content = <<-END.gsub(/^\s+\|/, '')
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

        it {
          should contain_file('structured_data_fact_custom.yaml').with({
            'ensure'  => 'file',
            'path'    => '/factsdir/custom.yaml',
            'content' => content,
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }
      end
    end # end on_supported_os(redhat)
  end # context "on RedHat"

  context 'on windows' do
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
        os_facts
      end

      context 'with fact and facts_dir specified' do
        let(:title) { 'fact1' }
        let(:params) do
          {
            :data => {
              'my_array' => ['one', 'two', 'three'],
              'my_hash' => { 'k' => 'v' },
            },
            :file => 'custom.yaml',
            :facts_dir => 'C:\factsdir',
          }
        end

        # These must exist or the coverage report lists these incorrectly as
        # untouched resources. These resources are all from the facter class.
        it { should contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d') }

        content = <<-END.gsub(/^\s+\|/, '')
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

        it {
          should contain_file('structured_data_fact_custom.yaml').with({
            'ensure'  => 'file',
            'content' => content,
            'path'    => 'C:\factsdir\custom.yaml',
            'owner'   => 'NT AUTHORITY\SYSTEM',
            'group'   => 'NT AUTHORITY\SYSTEM',
          })
        }
      end
    end # end on_supported_os(windows)
  end # context "on windows"
end
