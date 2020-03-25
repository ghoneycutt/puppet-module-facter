desc 'Alias for strings:generate'
task :doc => ['strings:generate']

desc 'Generate REFERENCE.md'
task :reference do
  sh 'puppet strings generate --format markdown'
end

desc 'Run acceptance tests'
RSpec::Core::RakeTask.new(:acceptance) do |t|
  t.pattern = 'spec/acceptance'
end
