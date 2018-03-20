require 'spec_helper'
describe 'facter::fact' do

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

    it {
      should contain_file('facts_file_fact1').with({
        'ensure'  => 'file',
        'path'    => '/factsdir/custom.txt',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
      })
    }

    it {
      should contain_file_line('fact_line_fact1').with({
        'name' => 'fact_line_fact1',
        'path' => '/factsdir/custom.txt',
        'line' => 'fact1=fact1value',
        'match' => '^fact1=\S.*$',
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
    it { should_not contain_file('facts_file_fact2') }

    it {
      should contain_file_line('fact_line_fact2').with({
        'name' => 'fact_line_fact2',
        'line' => 'fact2=fact2value',
        'path' => '/etc/facter/facts.d/facts.txt',
      })
    }
  end
end
