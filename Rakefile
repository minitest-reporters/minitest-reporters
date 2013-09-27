require "bundler/gem_tasks"
require "rake/testtask"

task :default => :test
Rake::TestTask.new do |t|
  t.pattern = "test/{unit,integration}/**/*_test.rb"
  t.verbose = true
end

Rake::TestTask.new("test:gallery") do |t|
  t.pattern = "test/gallery/**/*_test.rb"
  t.verbose = true
end

# The RubyMine reporter must be tested separately inside of RubyMine, and hence
# is not run in the gallery. The JUnit reporter writes to `test/reports` instead
# of having meaningful output. The guard reporter requires Guard, and I'm not
# really all that interested in setting it up for automated testing for such a
# simple reporter.
task :gallery do
  [
    "DefaultReporter",
    "JUnitReporter",
    "ProgressReporter",
    "RubyMateReporter",
    "SpecReporter"
  ].each do |reporter|
    puts
    puts "-" * 72
    puts "#{reporter}:"
    puts "-" * 72
    puts
    sh "rake test:gallery REPORTER=#{reporter}" do
      # Ignore failures. They're expected when you are running the gallery
      # test suite.
    end
  end
end
