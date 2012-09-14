require 'bundler/setup'
require 'minitest/autorun'

$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require 'minitest/reporters'
MiniTest::Reporters.use! eval("Minitest::Reporters::#{ARGV[0] || raise("give me a reporter name as ARGV 0")}.new")
