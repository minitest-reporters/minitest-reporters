require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :test

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.ruby_opts += ['-rubygems']
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end