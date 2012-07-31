# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'minitest/reporters/version'

Gem::Specification.new do |s|
  s.name        = 'minitest-reporters'
  s.version     = MiniTest::Reporters::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alexander Kern']
  s.email       = ['alex@kernul.com']
  s.homepage    = 'https://github.com/CapnKernul/minitest-reporters'
  s.summary     = %q{Create customizable MiniTest output formats}
  s.description = %q{Death to haphazard monkey-patching! Extend MiniTest through simple hooks.}

  s.rubyforge_project = 'minitest-reporters'

  s.add_dependency 'minitest', '>= 2.12', '< 4.0'
  s.add_dependency 'ansi'
  s.add_dependency 'powerbar'
  s.add_dependency 'builder'

  s.add_development_dependency 'rr'
  s.add_development_dependency 'maruku'
  s.add_development_dependency 'rake'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
