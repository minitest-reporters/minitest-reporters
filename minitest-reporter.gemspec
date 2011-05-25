# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'minitest-reporter/version'

Gem::Specification.new do |s|
  s.name        = 'minitest-reporter'
  s.version     = MiniTest::Reporter::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alexander Kern']
  s.email       = ['alex@kernul.com']
  s.homepage    = 'https://github.com/CapnKernul/minitest-reporter'
  s.summary     = %q{Adds reporters to MiniTest}
  s.description = %q{Allows you to extend MiniTest::Unit using reporters rather than monkey-patching}
  
  s.rubyforge_project = 'minitest-reporter'
  
  s.add_dependency 'minitest', '~> 2.0'
  s.add_dependency 'ansi'
  s.add_dependency 'ruby-progressbar'
  
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'maruku'
  s.add_development_dependency 'test_declarative'
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end