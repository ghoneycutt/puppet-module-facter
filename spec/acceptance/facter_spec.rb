
require 'spec_helper_acceptance'

describe 'facter class' do
  if Gem.win_platform?
    facts_d_dir = 'C:\ProgramData\PuppetLabs\facter\facts.d'
    facts_d_owner = 'NT AUTHORITY\SYSTEM'
    facts_d_group = 'NT AUTHORITY\SYSTEM'
    facts_d_mode = nil
    test_facts_file = 'C:\ProgramData\PuppetLabs\facter\facts.d\\test.txt'
    facts_file = 'C:\ProgramData\PuppetLabs\facter\facts.d\\facts.txt'
    facts_file_owner = 'NT AUTHORITY\SYSTEM'
    facts_file_group = 'NT AUTHORITY\SYSTEM'
    facts_file_mode = nil
  else
    facts_d_dir = '/etc/facter/facts.d'
    facts_d_owner = 'root'
    facts_d_group = 'root'
    facts_d_mode = '755'
    test_facts_file = '/etc/facter/facts.d/test.txt'
    facts_file = '/etc/facter/facts.d/facts.txt'
    facts_file_owner = 'root'
    facts_file_group = 'root'
    facts_file_mode = '644'
  end

  context 'with default values for all parameters' do
    context 'it should be idempotent' do
      pp = <<-EOS
      include facter
      EOS

      if Gem.win_platform?
        manifest = 'C:\manifest-default.pp'

        it 'creates manifest' do
          File.open(manifest, 'w') { |f| f.write(pp) }
          puts manifest
          puts File.read(manifest)
        end

        describe command("PsExec -accepteula -s 'C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet.bat' apply --debug #{manifest}") do
          its(:stderr) { should contain('with error code 0') }
        end

        describe command("PsExec -accepteula -s 'C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet.bat' apply --debug #{manifest}") do
          its(:stderr) { should contain('with error code 0') }
        end
      else
        it 'should work with no errors' do
          # Run it twice and test for idempotency
          apply_manifest(pp, :catch_failures => true)
          apply_manifest(pp, :catch_changes  => true)
        end
      end
    end

    context 'should contain resources' do
      describe file(facts_d_dir) do
        it { should be_directory }
        it { should be_owned_by facts_d_owner }
        # Serverspec (more specifically
        # Specinfra::Command::Windows::Base::File) does not support group, mode
        # or size for files on Windows.
        if host_inventory['platform'] != 'windows'
          it { should be_grouped_into facts_d_group }
          it { should be_mode facts_d_mode }
        end
      end

      describe file(facts_file) do
        it { should be_file }
        it { should be_owned_by facts_file_owner }
        # Serverspec (more specifically
        # Specinfra::Command::Windows::Base::File) does not support group, mode
        # or size for files on Windows.
        if host_inventory['platform'] != 'windows'
          it { should be_grouped_into facts_file_group }
          it { should be_mode facts_file_mode }
          its(:size) { should eq 0 }
        end
      end
    end
  end

  context 'with specifying facts_hash' do
    context 'should apply the manifest' do
      pp = <<-EOS
      class { 'facter':
        facts_hash => {
          'test_fact' => {
            value => 'test_value',
            file  => 'test.txt',
          },
        },
      }
      EOS

      if Gem.win_platform?
        manifest = 'C:\manifest-facts_hash.pp'

        it 'creates manifest' do
          File.open(manifest, 'w') { |f| f.write(pp) }
          puts manifest
          puts File.read(manifest)
        end

        describe command("PsExec -accepteula -s 'C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet.bat' apply --debug #{manifest}") do
          its(:stderr) { should contain('with error code 0') }
        end
      else
        it 'should work with no errors' do
          apply_manifest(pp, :catch_failures => true)
        end
      end
    end

    context 'and should contain facts' do
      describe file(test_facts_file) do
        its(:content) { should match %r{test_fact=test_value} }
      end

      describe command('facter -p test_fact') do
        its(:stdout) { should contain('test_value') }
      end
    end
  end

  context 'with setting ensure_facter_symlink to true' do
    if host_inventory['platform'] == 'windows'
      before { skip('Windows does not have symlinks. Skipping test.') }
    end

    it 'should apply the manifest' do
      pp = <<-EOS
      class { 'facter':
        ensure_facter_symlink => true,
      }
      EOS

      apply_manifest(pp, :catch_failures => true)
    end

    context 'and should have the symlink' do
      describe file('/usr/local/bin/facter') do
        it { should be_symlink }
        it { should be_linked_to '/opt/puppetlabs/bin/facter' }
      end

      describe command('/usr/local/bin/facter -p test_fact') do
        its(:stdout) { should contain('test_value') }
      end
    end
  end

  context 'with specify purge_facts_d as true' do
    context 'should apply the manifest' do
      pp = <<-EOS
      class { 'facter':
        purge_facts_d => true,
      }
      EOS

      if Gem.win_platform?
        manifest = 'C:\manifest-purge_facts.pp'

        it 'creates manifest' do
          File.open(manifest, 'w') { |f| f.write(pp) }
          puts manifest
          puts File.read(manifest)
        end

        describe command("PsExec -accepteula -s 'C:\\Program Files\\Puppet Labs\\Puppet\\bin\\puppet.bat' apply --debug #{manifest}") do
          its(:stderr) { should contain('with error code 0') }
        end
      else
        it 'should work with no errors' do
          apply_manifest(pp, :catch_failures => true)
        end
      end
    end

    context 'and should remove facts not managed by puppet' do
      describe file(test_facts_file) do
        it { should_not exist }
      end

      describe command('facter -p test_fact') do
        its(:stdout) { should_not contain('test_value') }
      end
    end
  end
end
