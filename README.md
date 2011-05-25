# minitest-reporter - reporters for MiniTest [![StillMaintained Status](http://stillmaintained.com/CapnKernul/minitest-reporter.png)](http://stillmaintained.com/CapnKernul/minitest-reporter) [![Build Status](http://travis-ci.org/CapnKernul/minitest-reporter.png)](http://travis-ci.org/CapnKernul/minitest-reporter) #

Allows you to extend MiniTest using reporters rather than monkey-patching.

## Installation ##

    gem install minitest-reporter

## Usage ##

In your `test_helper.rb` file, add the following lines:

    require 'minitest-reporter'
    MiniTest::Unit.runner = MiniTest::SuiteRunner.new
    MiniTest::Unit.runner.reporters << MiniTest::Reporters::ProgressReporter.new

Now, just run your tests; the reporter you specified will be used and make your
output look absolutely gorgeous! If you feel the need to write your own
reporter, just subclass `MiniTest::Reporter` and override the methods you'd
like. Take a look at the provided reporters for examples.

The following reporters are provided:

    MiniTest::Reporters::DefaultReporter # => Identical to the standard MiniTest reporter
    MiniTest::Reporters::SpecReporter # => Turn-like output that reads like a spec
    MiniTest::Reporters::ProgressReporter # => Fuubar-like output with a progress bar

I really like `ProgressReporter`.

## Note on Patches/Pull Requests ##

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, but do not mess with the `Rakefile`. If you want to have your own version, that is fine but bump the version in a commit by itself in another branch so I can ignore it when I pull.
* Send me a pull request. Bonus points for git flow feature branches.

## Resources ##

* [GitHub Repository](https://github.com/CapnKernul/minitest-reporter)
* [Documentation](http://rubydoc.info/github/CapnKernul/minitest-reporter)

## License ##

Minitest-reporter is licensed under the MIT License. See `LICENSE` for details.