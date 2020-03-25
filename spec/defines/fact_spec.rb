require 'spec_helper'

describe 'facter::fact' do
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

      context 'with fact and facts_dir specified' do
        let(:title) { 'fact1' }
        let(:params) do
          {
            :fact => 'fact1',
            :value => 'fact1value',
            :file => 'custom.txt',
            :facts_dir => '/factsdir',
          }
        end

        it { should contain_class('facter') }

        # These must exist or the coverage report lists these incorrectly as
        # untouched resources. These resources are all from the facter class.
        it { should contain_concat('facts_file') }
        it { should contain_file('facts_d_directory') }
        it { should contain_exec('mkdir_p-/etc/facter/facts.d') }

        it {
          should contain_concat('facts_file_fact1').with({
            'ensure'  => 'present',
            'path'    => '/factsdir/custom.txt',
            'owner'   => 'root',
            'group'   => 'root',
            'mode'    => '0644',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact1').with({
            'target'  => 'facts_file_fact1',
            'content' => 'fact1=fact1value',
          })
        }
      end

      context 'with fact specified ' do
        let(:title) { 'fact2' }
        let(:params) do
          {
            :fact => 'fact2',
            :value => 'fact2value',
          }
        end

        # Does not contain this file, because we are using the default which is
        # managed in the facter class.
        it { should_not contain_concat('facts_file_fact2') }

        it {
          should contain_concat__fragment('fact_line_fact2').with({
            'target'  => 'facts_file',
            'content' => 'fact2=fact2value',
          })
        }
      end

      context 'with fact specified with a space in the value' do
        let(:title) { 'fact1' }
        let(:params) do
          {
            :fact => 'fact1',
            :value => 'space in value',
          }
        end

        it {
          should contain_concat__fragment('fact_line_fact1').with({
            'content' => 'fact1=space in value',
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
            :fact => 'fact1',
            :value => 'fact1value',
            :file => 'custom.txt',
            :facts_dir => 'C:\factsdir',
          }
        end

        # These must exist or the coverage report lists these incorrectly as
        # untouched resources. These resources are all from the facter class.
        it { should contain_exec('mkdir_p-C:\ProgramData\PuppetLabs\facter\facts.d') }

        it {
          should contain_concat('facts_file_fact1').with({
            'ensure'  => 'present',
            'path'    => 'C:\factsdir\custom.txt',
            'owner'   => 'NT AUTHORITY\SYSTEM',
            'group'   => 'NT AUTHORITY\SYSTEM',
          })
        }

        it {
          should contain_concat__fragment('fact_line_fact1').with({
            'target'  => 'facts_file_fact1',
            'content' => 'fact1=fact1value',
          })
        }
      end

      context 'with fact specified ' do
        let(:title) { 'fact2' }
        let(:params) do
          {
            :fact => 'fact2',
            :value => 'fact2value',
          }
        end

        # Does not contain this file, because we are using the default which is
        # managed in the facter class.
        it { should_not contain_concat('facts_file_fact2') }

        it {
          should contain_concat__fragment('fact_line_fact2').with({
            'content' => 'fact2=fact2value',
          })
        }
      end
    end # end on_supported_os(windows)
  end # context "on windows"
end
