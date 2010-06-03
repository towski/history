require 'rubygems'
require 'resque/tasks'
require 'rake/testtask'

task "resque:setup" do
  require 'config'
end

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*test.rb']
  t.verbose = true
end
