require 'bundler/gem_tasks'
require 'mdn_query'
require 'pry'
require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new(:test) do |t, args|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files =
    if args.nil?
      FileList['test/**/*_test.rb']
    else
      FileList[*args]
    end
end

RuboCop::RakeTask.new(:lint)

task :repl do
  Pry.start
end

task default: [:lint, :test]
