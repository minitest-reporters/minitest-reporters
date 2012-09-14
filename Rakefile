require 'bundler/gem_tasks'

require 'rake/testtask'
Rake::TestTask.new(:default) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

# - RubyMineReporter only displays warning
# - JUnitReporter writes to test/reports instead of showing something + only reports for 1 file
# - GuardReporter shows nothing
task :gallery do
  tests = Dir["./test/gallery/*_gallery.rb"]
  reporters = if ENV["REPORTER"]
    ENV["REPORTER"].split(",")
  else
    puts "ENV['REPORTER'] not given, running all"
    Dir["lib/minitest/reporters/*_reporter.rb"].map do |r|
      File.read(r).match(/class (.*?Reporter)( < .*Reporter)?$/)[1]
    end
  end

  reporters.each do |reporter|
    puts "#{reporter} output:"
    sh "ruby #{tests.map{|t| "-r#{t}" }.join(" ")} -e '' #{reporter} || test 1"
    puts "-" * 72
    puts
  end
end
