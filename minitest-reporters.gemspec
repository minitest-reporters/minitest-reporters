# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'minitest/reporters/version'

Gem::Specification.new do |s|
  s.name        = 'minitest-reporters'
  s.version     = Minitest::Reporters::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Alexander Kern']
  s.email       = ['alex@kernul.com']
  s.homepage    = 'https://github.com/minitest-reporters/minitest-reporters'
  s.summary     = %q{Create customizable Minitest output formats}
  s.description = %q{Death to haphazard monkey-patching! Extend Minitest through simple hooks.}
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.4.0' # keep in sync with gemspec and ci.yml

  s.add_dependency 'minitest', '>= 5.0', '< 7'
  s.add_dependency 'ansi'
  s.add_dependency 'ruby-progressbar'
  s.add_dependency 'builder'

  s.files = `git ls-files`.split("\n").select do |f|
    f.start_with?("lib/") || %w[LICENSE README.md CHANGELOG.md].include?(f)
  end

  s.require_paths = ['lib']
end
