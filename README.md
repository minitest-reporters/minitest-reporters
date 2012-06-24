# minitest-reporters - create customizable MiniTest output formats [![StillMaintained Status](http://stillmaintained.com/CapnKernul/minitest-reporters.png)](http://stillmaintained.com/CapnKernul/minitest-reporters) [![Build Status](http://travis-ci.org/CapnKernul/minitest-reporters.png)](http://travis-ci.org/CapnKernul/minitest-reporters) #

Death to haphazard monkey-patching! Extend MiniTest through simple hooks.

## Installation ##

    gem install minitest-reporters

## Usage ##

In your `test_helper.rb` file, add the following lines:

    require 'minitest/reporters'
    MiniTest::Runners.choose_runner!

The correct formatter will be chosen for Textmate/Rubymine/console.
If you feel the need to write your own reporter, just `include MiniTest::Reporter` and override the methods you'd like.
Take a look at the provided reporters for examples.

Don't like progressbar ?

    MiniTest::Runners.choose_runner! :console => MiniTest::Reporters::SpecReporter.new


The following reporters are provided:

    MiniTest::Reporters::DefaultReporter # => Identical to the standard MiniTest reporter
    MiniTest::Reporters::SpecReporter # => Turn-like output that reads like a spec
    MiniTest::Reporters::ProgressReporter # => Fuubar-like output with a progress bar
    MiniTest::Reporters::RubyMateReporter # => Simple reporter designed for RubyMate
    MiniTest::Reporters::RubyMineReporter # => Reporter designed for RubyMine IDE and TeamCity CI server; see below
    MiniTest::Reporters::GuardReporter # => Integrates with guard-minitest to provide on-screen notifications

## TODO ##

* Add some example images of the reporters.

## Note on Patches/Pull Requests ##

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, but do not mess with the `Rakefile`. If you want to have your own version, that is fine but bump the version in a commit by itself in another branch so I can ignore it when I pull.
* Send me a pull request. Bonus points for git flow feature branches.

## Resources ##

* [GitHub Repository](https://github.com/CapnKernul/minitest-reporters)
* [Documentation](http://rubydoc.info/github/CapnKernul/minitest-reporters)

## License ##

Minitest-reporters is licensed under the MIT License. See `LICENSE` for details.
