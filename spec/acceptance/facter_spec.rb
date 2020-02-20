require 'spec_helper_acceptance'

describe 'facter class' do
  context 'with default values for all parameters' do
    context 'it should be idempotent' do
      it 'should work with no errors' do
        pp = <<-EOS
        include facter
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        apply_manifest(pp, :catch_changes  => true)
      end
    end

    context 'should contain resources' do
      describe file('/etc/facter/facts.d') do
        it { should be_directory }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 0775 }
      end

      describe file('/etc/facter/facts.d/facts.txt') do
        it { should be_file }
        it { should be_owned_by 'root' }
        it { should be_grouped_into 'root' }
        it { should be_mode 0644 }
        its(:size) { should eq 0 }
      end
    end
  end

  context 'with specifying facts' do
    it 'should contain facts' do
      pp = <<-EOS
      class { 'facter':
        facts_hash => {
          'test_fact' => 'test_value',
        },
      }
      EOS

      apply_manifest(pp, :catch_failures => true)

      describe file('/etc/facter/facts.d/facts.txt') do
        its(:content) { should match %r{test_fact=test_value} }
      end

      describe command('facter -p test_fact') do
        its(:stdout) { should contain('test_value') }
      end
    end
  end
end
