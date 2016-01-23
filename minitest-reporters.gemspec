# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'minitest/reporters/version'

Gem::Specification.new do |s|
  s.name        = 'minitest-reporters'
  s.version     = Minitest::Reporters::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alexander Kern']
  s.email       = ['alex@kernul.com']
  s.homepage    = 'https://github.com/CapnKernul/minitest-reporters'
  s.summary     = %q{Create customizable Minitest output formats}
  s.description = %q{Death to haphazard monkey-patching! Extend Minitest through simple hooks.}

  s.required_ruby_version = '>= 1.9.3'
  s.rubyforge_project = 'minitest-reporters'

  s.add_dependency 'minitest', '5.8.3'
  s.add_dependency 'ansi', '1.5.0'
  s.add_dependency 'ruby-progressbar', '1.7.5'
  s.add_dependency 'builder', '3.2.2'

  s.add_development_dependency 'bundler', '1.7.9'
  s.add_development_dependency 'maruku', '0.7.2'
  s.add_development_dependency 'rake', '10.4.2'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
