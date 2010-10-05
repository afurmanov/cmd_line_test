require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/shoulda/cli_test.rb', 'test/unit/cli_test.rb']
  t.verbose = true
end

task :default => "test"
