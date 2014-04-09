require 'spec_helper'
describe 'facter::fact' do

  context 'with fact and folder specified' do
    let(:title) { 'fact1' }
    let(:params) do
      {
        :fact => 'fact1',
        :value => 'fact1value',
        :match => '^fact1=\S*$',
        :file => 'facts.txt',
        :facts_dir => "/factsdir",
      }
    end

    it {
      should contain_file("facts_file_fact1").with({
        'ensure'  => 'file',
        'path'    => '/factsdir/facts.txt',
        'require' => 'File[facts_d_directory]',
      })
    }

    it {
      should contain_file_line("fact_line_fact1").with({
        'name' => 'fact_line_fact1',
        'path' => '/factsdir/facts.txt',
        'line' => 'fact1=fact1value',
        'match' => '^fact1=\S*$',
      })
    }

    it { should contain_class('Facter::Fact[fact1]')}

    it { should have_file_resource_count(1) }

    it { should have_file_line_resource_count(1) }

  end

  context 'with fact specified ' do
    let(:title) { 'fact2' }
    let(:params) do
      {
        :fact => 'fact2',
        :value => 'fact2value',
      }
    end

    it {
      should contain_file_line("fact_line_fact2").with({
        'name' => 'fact_line_fact2',
        'line' => 'fact2=fact2value',
      })
    }

    it { should contain_class('Facter::Fact[fact2]')}

    it { should_not contain_file('facts_file_fact2') }

    it { should have_file_resource_count(0) }

    it { should have_file_line_resource_count(1) }

  end

end
