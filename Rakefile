require "bundler/gem_tasks"
require "rake/testtask"

task :default => :test
Rake::TestTask.new do |t|
  t.pattern = "test/{unit,integration}/**/*_test.rb"
  t.verbose = true
end

rubymine_home = [
  ENV["RUBYMINE_HOME"],
  "../rubymine-contrib/ruby-testing/src/rb/testing/patch/common",
  "/Applications/RubyMine.app/rb/testing/patch/common",
].compact.detect { |d| Dir.exist?(d) }

Rake::TestTask.new("test:gallery") do |t|
  t.pattern = "test/gallery/**/*_test.rb"
  t.verbose = true
  t.libs << rubymine_home
end

# - RubyMineReporter must be tested separately inside of RubyMine
# - JUnitReporter normally writes to `test/reports` instead of stdout
task :gallery do
  unless rubymine_home
    warn "To see RubyMineReporter supply RUBYMINE_HOME= or git clone git://git.jetbrains.org/idea/contrib.git ../rubymine-contrib"
    exit 1
  end

  [
    "Pride",
    "DefaultReporter",
    "JUnitReporter",
    "ProgressReporter",
    "RubyMateReporter",
    "SpecReporter",
    "RubyMineReporter"
  ].each do |reporter|
    puts
    puts "-" * 72
    puts "Running gallery tests using #{reporter}..."
    puts "-" * 72
    puts

    sh "rake test:gallery REPORTER=#{reporter}" do
      # Ignore failures. They're expected when you are running the gallery
      # test suite.
    end
    sh "cat test/reports/*" if reporter == "JUnitReporter"
  end
end
