require 'bundler/gem_tasks'
require 'mdn_query'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = if ARGV.size > 1
                   FileList[*ARGV[1..-1]]
                 else
                   FileList['test/**/*_test.rb']
                 end
end

RuboCop::RakeTask.new(:lint)

task default: [:lint, :test]
