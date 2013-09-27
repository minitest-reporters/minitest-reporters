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
  t.libs << "/Applications/RubyMine.app/rb/testing/patch/common"
end

# - RubyMineReporter must be tested separately inside of RubyMine
# - JUnitReporter normally writes to `test/reports` instead of stdout
# - GuardReporter requires Guard, and I'm not
#   really all that interested in setting it up for automated testing for such a
#   simple reporter.
task :gallery do
  [
    "DefaultReporter",
    "JUnitReporter",
    "ProgressReporter",
    "RubyMateReporter",
    "SpecReporter",
    "RubyMineReporter",
    "GuardReporter"
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
    sh "cat test/reports/*" if reporter == "JUnitReporter"
  end
end
